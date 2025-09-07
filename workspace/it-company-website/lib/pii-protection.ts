import crypto from 'crypto';

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || crypto.randomBytes(32).toString('hex');
const IV_LENGTH = 16;

// PII（個人識別情報）の定義
export interface PIIField {
  type: 'email' | 'phone' | 'ssn' | 'credit_card' | 'address' | 'name';
  encrypted: boolean;
  masked: boolean;
}

// データ暗号化
export class DataEncryption {
  private static algorithm = 'aes-256-cbc';
  
  static encrypt(text: string): string {
    const iv = crypto.randomBytes(IV_LENGTH);
    const cipher = crypto.createCipheriv(
      this.algorithm,
      Buffer.from(ENCRYPTION_KEY, 'hex'),
      iv
    );
    
    let encrypted = cipher.update(text);
    encrypted = Buffer.concat([encrypted, cipher.final()]);
    
    return iv.toString('hex') + ':' + encrypted.toString('hex');
  }
  
  static decrypt(text: string): string {
    const textParts = text.split(':');
    const iv = Buffer.from(textParts.shift()!, 'hex');
    const encryptedText = Buffer.from(textParts.join(':'), 'hex');
    
    const decipher = crypto.createDecipheriv(
      this.algorithm,
      Buffer.from(ENCRYPTION_KEY, 'hex'),
      iv
    );
    
    let decrypted = decipher.update(encryptedText);
    decrypted = Buffer.concat([decrypted, decipher.final()]);
    
    return decrypted.toString();
  }
}

// データマスキング
export class DataMasking {
  static maskEmail(email: string): string {
    const [localPart, domain] = email.split('@');
    if (!domain) return '***@***.***';
    
    const maskedLocal = localPart.substring(0, 2) + '***';
    return `${maskedLocal}@${domain}`;
  }
  
  static maskPhone(phone: string): string {
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length < 10) return '***-***-****';
    
    return `***-***-${cleaned.substring(cleaned.length - 4)}`;
  }
  
  static maskCreditCard(cardNumber: string): string {
    const cleaned = cardNumber.replace(/\s/g, '');
    if (cleaned.length < 12) return '****-****-****-****';
    
    return `****-****-****-${cleaned.substring(cleaned.length - 4)}`;
  }
  
  static maskSSN(ssn: string): string {
    const cleaned = ssn.replace(/\D/g, '');
    if (cleaned.length !== 9) return '***-**-****';
    
    return `***-**-${cleaned.substring(5)}`;
  }
  
  static maskAddress(address: string): string {
    const parts = address.split(',');
    if (parts.length < 2) return '***';
    
    // 番地のみをマスク
    return parts[0].substring(0, 3) + '***' + parts.slice(1).join(',');
  }
  
  static maskName(name: string): string {
    const parts = name.split(' ');
    return parts.map(part => 
      part.charAt(0) + '*'.repeat(Math.max(0, part.length - 1))
    ).join(' ');
  }
}

// PII検出
export class PIIDetector {
  private static patterns = {
    email: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g,
    phone: /(\+?\d{1,3}[-.\s]?)?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}/g,
    ssn: /\b\d{3}-\d{2}-\d{4}\b/g,
    creditCard: /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g,
    ipAddress: /\b(?:\d{1,3}\.){3}\d{1,3}\b/g
  };
  
  static detectPII(text: string): { type: string; value: string; position: number }[] {
    const results: { type: string; value: string; position: number }[] = [];
    
    for (const [type, pattern] of Object.entries(this.patterns)) {
      let match;
      const regex = new RegExp(pattern);
      while ((match = regex.exec(text)) !== null) {
        results.push({
          type,
          value: match[0],
          position: match.index
        });
      }
    }
    
    return results;
  }
  
  static sanitizeText(text: string): string {
    let sanitized = text;
    
    // Email addresses
    sanitized = sanitized.replace(this.patterns.email, (match) => 
      DataMasking.maskEmail(match)
    );
    
    // Phone numbers
    sanitized = sanitized.replace(this.patterns.phone, (match) => 
      DataMasking.maskPhone(match)
    );
    
    // SSN
    sanitized = sanitized.replace(this.patterns.ssn, '***-**-****');
    
    // Credit cards
    sanitized = sanitized.replace(this.patterns.creditCard, (match) => 
      DataMasking.maskCreditCard(match)
    );
    
    // IP addresses
    sanitized = sanitized.replace(this.patterns.ipAddress, '***.***.***.***');
    
    return sanitized;
  }
}

// ログのサニタイズ
export class LogSanitizer {
  static sanitizeLog(logEntry: any): any {
    if (typeof logEntry === 'string') {
      return PIIDetector.sanitizeText(logEntry);
    }
    
    if (typeof logEntry === 'object' && logEntry !== null) {
      const sanitized: any = Array.isArray(logEntry) ? [] : {};
      
      for (const [key, value] of Object.entries(logEntry)) {
        // センシティブなフィールド名をチェック
        if (this.isSensitiveField(key)) {
          sanitized[key] = '[REDACTED]';
        } else if (typeof value === 'string') {
          sanitized[key] = PIIDetector.sanitizeText(value);
        } else if (typeof value === 'object') {
          sanitized[key] = this.sanitizeLog(value);
        } else {
          sanitized[key] = value;
        }
      }
      
      return sanitized;
    }
    
    return logEntry;
  }
  
  private static isSensitiveField(fieldName: string): boolean {
    const sensitiveFields = [
      'password', 'pwd', 'secret', 'token', 'apikey', 'api_key',
      'private_key', 'credit_card', 'cvv', 'ssn', 'social_security'
    ];
    
    const lowerFieldName = fieldName.toLowerCase();
    return sensitiveFields.some(field => lowerFieldName.includes(field));
  }
}

// GDPR/CCPA準拠のデータ処理
export class PrivacyCompliance {
  // データの匿名化
  static anonymizeData(data: any): any {
    const anonymized = { ...data };
    
    // UUIDの生成
    anonymized.id = crypto.randomUUID();
    
    // PIIフィールドの処理
    if (anonymized.email) {
      anonymized.email = DataMasking.maskEmail(anonymized.email);
    }
    if (anonymized.phone) {
      anonymized.phone = DataMasking.maskPhone(anonymized.phone);
    }
    if (anonymized.name) {
      delete anonymized.name;
    }
    if (anonymized.address) {
      delete anonymized.address;
    }
    
    // タイムスタンプの丸め（日単位）
    if (anonymized.createdAt) {
      const date = new Date(anonymized.createdAt);
      date.setHours(0, 0, 0, 0);
      anonymized.createdAt = date.toISOString();
    }
    
    return anonymized;
  }
  
  // データの仮名化
  static pseudonymizeData(data: any, userId: string): any {
    const pseudonymized = { ...data };
    
    // 一貫した仮名IDの生成
    const hash = crypto.createHash('sha256');
    hash.update(userId + ENCRYPTION_KEY);
    pseudonymized.pseudoId = hash.digest('hex');
    
    // 元のIDを削除
    delete pseudonymized.id;
    delete pseudonymized.userId;
    
    // PIIを暗号化
    if (pseudonymized.email) {
      pseudonymized.email = DataEncryption.encrypt(pseudonymized.email);
    }
    if (pseudonymized.phone) {
      pseudonymized.phone = DataEncryption.encrypt(pseudonymized.phone);
    }
    
    return pseudonymized;
  }
}