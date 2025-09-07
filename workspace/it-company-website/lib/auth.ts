import crypto from 'crypto';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'change-this-in-production';
const JWT_EXPIRES_IN = '24h';
const REFRESH_TOKEN_EXPIRES = 7 * 24 * 60 * 60 * 1000; // 7日

export interface User {
  id: string;
  email: string;
  role: 'admin' | 'user';
  passwordHash?: string;
}

export interface Session {
  userId: string;
  email: string;
  role: string;
  iat: number;
  exp: number;
}

// パスワードのハッシュ化
export async function hashPassword(password: string): Promise<string> {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return `${salt}:${hash}`;
}

// パスワードの検証
export async function verifyPassword(password: string, storedHash: string): Promise<boolean> {
  const [salt, originalHash] = storedHash.split(':');
  const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512').toString('hex');
  return hash === originalHash;
}

// JWTトークンの生成
export function generateAccessToken(user: User): string {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role
    },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

// リフレッシュトークンの生成
export function generateRefreshToken(): string {
  return crypto.randomBytes(32).toString('hex');
}

// JWTトークンの検証
export function verifyAccessToken(token: string): Session | null {
  try {
    return jwt.verify(token, JWT_SECRET) as Session;
  } catch (error) {
    return null;
  }
}

// セッション管理
export class SessionManager {
  private static sessions = new Map<string, { user: User; refreshToken: string; expiresAt: Date }>();
  
  static createSession(user: User): { accessToken: string; refreshToken: string } {
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken();
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_EXPIRES);
    
    this.sessions.set(refreshToken, { user, refreshToken, expiresAt });
    
    return { accessToken, refreshToken };
  }
  
  static refreshSession(refreshToken: string): { accessToken: string; refreshToken: string } | null {
    const session = this.sessions.get(refreshToken);
    
    if (!session || session.expiresAt < new Date()) {
      this.sessions.delete(refreshToken);
      return null;
    }
    
    // 古いリフレッシュトークンを削除
    this.sessions.delete(refreshToken);
    
    // 新しいセッションを作成
    return this.createSession(session.user);
  }
  
  static revokeSession(refreshToken: string): void {
    this.sessions.delete(refreshToken);
  }
  
  static cleanupExpiredSessions(): void {
    const now = new Date();
    for (const [token, session] of this.sessions.entries()) {
      if (session.expiresAt < now) {
        this.sessions.delete(token);
      }
    }
  }
}

// 定期的なクリーンアップ
setInterval(() => {
  SessionManager.cleanupExpiredSessions();
}, 60 * 60 * 1000); // 1時間ごと