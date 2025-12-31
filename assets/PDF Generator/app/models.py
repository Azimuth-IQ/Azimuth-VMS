from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String, unique=True, index=True)
    password_hash = Column(String)
    is_admin = Column(Boolean, default=False)

class Attachment(Base):
    __tablename__ = "attachments"
    
    id = Column(Integer, primary_key=True, index=True)
    volunteer_id = Column(Integer, ForeignKey("volunteers.id", ondelete="CASCADE"))
    name = Column(String, nullable=False)  # e.g., "البطاقة الوطنية", "جواز السفر"
    file_path = Column(String, nullable=False)
    
    volunteer = relationship("Volunteer", back_populates="attachment_list")

class Volunteer(Base):
    __tablename__ = "volunteers"

    id = Column(Integer, primary_key=True, index=True)
    
    # All 30 text fields matching PDF form fields exactly
    text1 = Column(String, nullable=True)   # رقم الاستمارة
    text2 = Column(String, nullable=True)   # اسم المجموعة والرمز
    text3 = Column(String, nullable=True)   # الاسم الرباعي واللقب
    text4 = Column(String, nullable=True)   # التحصيل الدراسي
    text5 = Column(String, nullable=True)   # المواليد
    text6 = Column(String, nullable=True)   # الحالة الاجتماعية
    text7 = Column(String, nullable=True)   # عدد الابناء
    text8 = Column(String, nullable=True)   # اسم الام الثلاثي واللقب
    text9 = Column(String, nullable=True)   # رقم الموبايل
    text10 = Column(String, nullable=True)  # العنوان الحالي
    text11 = Column(String, nullable=True)  # اقرب نقطة دالة
    text12 = Column(String, nullable=True)  # اسم المختار ومسؤول المجلس البلدي
    text13 = Column(String, nullable=True)  # دائرة الاحوال
    text14 = Column(String, nullable=True)  # العنوان السابق
    text15 = Column(String, nullable=True)  # عدد المشاركات في الخدمة التطوعية في العتبة
    text16 = Column(String, nullable=True)  # المهنة
    text17 = Column(String, nullable=True)  # العنوان الوظيفي
    text18 = Column(String, nullable=True)  # اسم الدائرة
    text19 = Column(String, nullable=True)  # الانتماء السياسي
    text20 = Column(String, nullable=True)  # الموهبة والخبرة
    text21 = Column(String, nullable=True)  # اللغات التي يجيدها
    text22 = Column(String, nullable=True)  # رقم الهوية او البطاقة الوطنية
    text23 = Column(String, nullable=True)  # السجل
    text24 = Column(String, nullable=True)  # الصحيفة
    text25 = Column(String, nullable=True)  # رقم البطاقة التموينية
    text26 = Column(String, nullable=True)  # اسم الوكيل
    text27 = Column(String, nullable=True)  # رقم مركز التموين
    text28 = Column(String, nullable=True)  # رقم بطاقة السكن
    text29 = Column(String, nullable=True)  # جهة اصدارها
    text30 = Column(String, nullable=True)  # NO
    
    photo_path = Column(String, nullable=True)
    
    # Relationship to attachments
    attachment_list = relationship("Attachment", back_populates="volunteer", cascade="all, delete-orphan")
