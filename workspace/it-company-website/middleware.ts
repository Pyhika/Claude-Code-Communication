import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import securityHeaders from './security-headers.json';

export function middleware(request: NextRequest) {
  const response = NextResponse.next();
  
  // セキュリティヘッダーの適用
  Object.entries(securityHeaders.headers).forEach(([key, value]) => {
    response.headers.set(key, value as string);
  });
  
  // CSRFトークンの生成と検証
  const csrfToken = request.cookies.get('csrf-token');
  if (!csrfToken) {
    const newToken = generateCSRFToken();
    response.cookies.set('csrf-token', newToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 3600
    });
  }
  
  // レート制限の実装
  const ip = request.ip || request.headers.get('x-forwarded-for') || '';
  if (isRateLimited(ip)) {
    return new NextResponse('Too Many Requests', { status: 429 });
  }
  
  return response;
}

function generateCSRFToken(): string {
  const array = new Uint8Array(32);
  crypto.getRandomValues(array);
  return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('');
}

// 簡易的なレート制限（本番環境ではRedisなどを使用）
const requestCounts = new Map<string, { count: number; resetAt: number }>();

function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const limit = 100; // 1分間に100リクエストまで
  const window = 60000; // 1分間
  
  const record = requestCounts.get(ip);
  
  if (!record || record.resetAt < now) {
    requestCounts.set(ip, { count: 1, resetAt: now + window });
    return false;
  }
  
  if (record.count >= limit) {
    return true;
  }
  
  record.count++;
  return false;
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
};