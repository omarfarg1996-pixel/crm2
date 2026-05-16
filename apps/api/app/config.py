"""
Commerce AI Core - API Configuration Module

يحتوي هذا الملف على إعدادات التطبيق الرئيسية باستخدام Pydantic Settings.
جميع الإعدادات تُحمّل من متغيرات البيئة مع قيم افتراضية آمنة للتطوير.

القواعد:
- لا تضع أسرارًا حقيقية في الكود
- استخدم .env.local للتطوير المحلي
- استخدم secrets management في الإنتاج
- كل إعداد يجب أن يكون له قيمة افتراضية آمنة
"""

from functools import lru_cache
from typing import List, Optional

from pydantic_settings import BaseSettings, SettingsConfigDict


class DatabaseSettings(BaseSettings):
    """إعدادات قاعدة البيانات PostgreSQL"""
    
    host: str = "localhost"
    port: int = 5432
    name: str = "commerce_ai_core"
    user: str = "postgres"
    password: str = "postgres"
    
    @property
    def url(self) -> str:
        """بناء connection URL لقاعدة البيانات"""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.name}"
    
    @property
    def async_url(self) -> str:
        """بناء async connection URL"""
        return f"postgresql+asyncpg://{self.user}:{self.password}@{self.host}:{self.port}/{self.name}"
    
    class Config:
        env_prefix = "DATABASE_"


class RedisSettings(BaseSettings):
    """إعدادات Redis للتخزين المؤقت و task queues"""
    
    host: str = "localhost"
    port: int = 6379
    password: Optional[str] = None
    db: int = 0
    
    @property
    def url(self) -> str:
        """بناء Redis connection URL"""
        if self.password:
            return f"redis://:{self.password}@{self.host}:{self.port}/{self.db}"
        return f"redis://{self.host}:{self.port}/{self.db}"
    
    class Config:
        env_prefix = "REDIS_"


class TemporalSettings(BaseSettings):
    """إعدادات Temporal workflow engine"""
    
    host: str = "localhost"
    port: int = 7233
    namespace: str = "default"
    task_queue: str = "commerce-ai-core-tasks"
    
    @property
    def target(self) -> str:
        """بناء Temporal target string"""
        return f"{self.host}:{self.port}"
    
    class Config:
        env_prefix = "TEMPORAL_"


class QdrantSettings(BaseSettings):
    """إعدادات Qdrant vector database للـ AI memory"""
    
    host: str = "localhost"
    port: int = 6333
    api_key: Optional[str] = None
    https: bool = False
    
    @property
    def url(self) -> str:
        """بناء Qdrant URL"""
        scheme = "https" if self.https else "http"
        return f"{scheme}://{self.host}:{self.port}"
    
    class Config:
        env_prefix = "QDRANT_"


class MinIOSettings(BaseSettings):
    """إعدادات MinIO/S3 object storage"""
    
    endpoint: str = "localhost:9000"
    access_key: str = "minioadmin"
    secret_key: str = "minioadminpassword"
    bucket: str = "commerce-ai-core"
    use_ssl: bool = False
    
    class Config:
        env_prefix = "MINIO_"


class SecuritySettings(BaseSettings):
    """إعدادات الأمان والمصادقة"""
    
    jwt_secret_key: str = "dev-secret-key-change-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expiration_minutes: int = 30
    encryption_key: str = "dev-encryption-key-32-bytes-long!"
    
    class Config:
        env_prefix = ""


class APISettings(BaseSettings):
    """إعدادات API server"""
    
    host: str = "0.0.0.0"
    port: int = 8000
    workers: int = 4
    reload: bool = True
    log_level: str = "INFO"
    
    class Config:
        env_prefix = "API_"


class FeatureFlags(BaseSettings):
    """Feature flags لتفعيل/تعطيل الميزات"""
    
    enable_ai_decisions: bool = True
    enable_human_approval: bool = True
    enable_auto_send: bool = False
    
    class Config:
        env_prefix = "ENABLE_"


class Settings(BaseSettings):
    """
    الإعدادات الرئيسية للتطبيق
    
    تجمع جميع فئات الإعدادات الفرعية في مكان واحد.
    تستخدم SettingsConfigDict لدمج الإعدادات من مصادر متعددة.
    """
    
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )
    
    # معلومات التطبيق
    environment: str = "development"
    app_name: str = "Commerce AI Core"
    debug: bool = True
    
    # إعدادات فرعية
    database: DatabaseSettings = DatabaseSettings()
    redis: RedisSettings = RedisSettings()
    temporal: TemporalSettings = TemporalSettings()
    qdrant: QdrantSettings = QdrantSettings()
    minio: MinIOSettings = MinIOSettings()
    security: SecuritySettings = SecuritySettings()
    api: APISettings = APISettings()
    features: FeatureFlags = FeatureFlags()
    
    # CORS origins المسموحة
    cors_origins: List[str] = [
        "http://localhost:3000",
        "http://localhost:8000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:8000",
    ]
    
    @property
    def is_production(self) -> bool:
        """هل نعمل في بيئة إنتاج؟"""
        return self.environment == "production"
    
    @property
    def is_development(self) -> bool:
        """هل نعمل في بيئة تطوير؟"""
        return self.environment == "development"
    
    @property
    def is_testing(self) -> bool:
        """هل نعمل في بيئة اختبار؟"""
        return self.environment == "testing"


@lru_cache()
def get_settings() -> Settings:
    """
    الحصول على إعدادات التطبيق (cached)
    
    تستخدم lru_cache لضمان تحميل الإعدادات مرة واحدة فقط.
    هذا يحسن الأداء ويضمن اتساق الإعدادات عبر التطبيق.
    
    Returns:
        Settings: كائن الإعدادات الرئيسي
    """
    return Settings()


# إنشاء instance عالمي للإعدادات للاستخدام السريع
settings = get_settings()
