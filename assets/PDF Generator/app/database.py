from sqlalchemy import create_engine, event
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

# Use /data directory for persistent storage in Cloud Run
DATA_DIR = os.environ.get("DATA_DIR", ".")
os.makedirs(DATA_DIR, exist_ok=True)

SQLALCHEMY_DATABASE_URL = f"sqlite:///{DATA_DIR}/volunteers_v2.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

# Configure SQLite for GCS FUSE compatibility
# Use DELETE journaling mode instead of WAL (better for cloud storage)
@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    # Use DELETE mode - compatible with cloud storage (avoids WAL file issues)
    cursor.execute("PRAGMA journal_mode=DELETE")
    # Synchronous FULL for data integrity on cloud storage
    cursor.execute("PRAGMA synchronous=FULL")
    cursor.close()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
