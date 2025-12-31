from app import models, database
from sqlalchemy.orm import Session

db = database.SessionLocal()
try:
    # Create a dummy volunteer if none exists
    if db.query(models.Volunteer).count() == 0:
        v = models.Volunteer(text1="Test")
        db.add(v)
        db.commit()

    volunteer = db.query(models.Volunteer).first()
    print(f"Type: {type(volunteer)}")
    try:
        print(f"Value: {volunteer['text1']}")
    except Exception as e:
        print(f"Error accessing ['text1']: {e}")
        
    try:
        print(f"Value: {volunteer.text1}")
    except Exception as e:
        print(f"Error accessing .text1: {e}")

finally:
    db.close()
