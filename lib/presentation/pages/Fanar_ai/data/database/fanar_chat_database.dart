// Local SQLite database for persisting conversations and messages.
// Uses sqflite — already present in the project.

import 'dart:developer';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../models/conversation.dart';

class FanarChatDatabase {
  FanarChatDatabase._();
  static final FanarChatDatabase instance = FanarChatDatabase._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'fanar_chat.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        title    TEXT    NOT NULL,
        createdAt TEXT   NOT NULL,
        updatedAt TEXT   NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        conversationId INTEGER NOT NULL,
        role           TEXT    NOT NULL,
        content        TEXT    NOT NULL,
        timestamp      TEXT    NOT NULL,
        FOREIGN KEY (conversationId) REFERENCES conversations(id) ON DELETE CASCADE
      )
    ''');

    // Index for fast per-conversation message queries.
    await db.execute(
      'CREATE INDEX idx_messages_conv ON messages(conversationId)',
    );
  }

  // ─── Conversations ────────────────────────────────────────────────────────

  Future<Conversation> insertConversation(Conversation conv) async {
    final db = await database;
    final id = await db.insert('conversations', conv.toDb());
    log('Inserted conversation id=$id', name: 'FanarChatDatabase');
    return conv.copyWith(id: id);
  }

  Future<List<Conversation>> getAllConversations() async {
    final db = await database;
    final rows = await db.query('conversations', orderBy: 'updatedAt DESC');
    return rows.map(Conversation.fromDb).toList();
  }

  Future<List<Conversation>> searchConversations(String query) async {
    final db = await database;
    final rows = await db.query(
      'conversations',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return rows.map(Conversation.fromDb).toList();
  }

  Future<void> updateConversationTitle(int id, String title) async {
    final db = await database;
    await db.update(
      'conversations',
      {'title': title, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> touchConversation(int id) async {
    final db = await database;
    await db.update(
      'conversations',
      {'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteConversation(int id) async {
    final db = await database;
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
    // Messages are cascade-deleted by the foreign key — but sqflite doesn't
    // enforce foreign keys by default, so we delete them explicitly.
    await db.delete('messages', where: 'conversationId = ?', whereArgs: [id]);
  }

  // ─── Messages ─────────────────────────────────────────────────────────────

  Future<ChatMessage> insertMessage(ChatMessage msg) async {
    final db = await database;
    final id = await db.insert('messages', msg.toDb());
    return msg.copyWith(id: id);
  }

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final db = await database;
    final rows = await db.query(
      'messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(ChatMessage.fromDb).toList();
  }

  Future<void> deleteMessage(int id) async {
    final db = await database;
    await db.delete('messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
