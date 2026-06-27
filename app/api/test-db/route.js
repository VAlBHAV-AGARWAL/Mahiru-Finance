import { NextResponse } from 'next/server';
const db = require('@/lib/db');

export async function GET() {
  try {
    // Query list of all user-created tables in SQLite database
    const tables = await db.queryAll("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
    
    return NextResponse.json({
      success: true,
      message: 'SQLite database connection successful and schema initialized!',
      tables: tables.map(t => t.name)
    });
  } catch (error) {
    return NextResponse.json({
      success: false,
      message: 'Failed to query SQLite database',
      error: error.message
    }, { status: 500 });
  }
}
