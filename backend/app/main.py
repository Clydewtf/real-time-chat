from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import select
import db
import models
import schemas
import auth


app = FastAPI()

models.Base.metadata.create_all(bind=db.engine)


@app.post("/auth/register", response_model=schemas.RegisterResponse)
def register_user(payload: dict, session: Session = Depends(db.get_db)):
    user_data = payload.get("input")
    if not user_data:
        raise HTTPException(status_code=400, detail="Missing input payload")

    email = user_data.get("email")
    password = user_data.get("password")

    stmt = select(models.User).where(models.User.email == email)  # type: ignore
    existing_user = session.execute(stmt).scalars().first()
    if existing_user:
        return {"success": False, "message": "Email already registered", "token": None}

    hashed = auth.hash_password(password)
    new_user = models.User(email=email, password_hash=hashed)
    session.add(new_user)
    session.commit()
    session.refresh(new_user)

    token = auth.create_jwt(str(new_user.id))
    return {"success": True, "message": "User registered", "token": token}


@app.post("/auth/login", response_model=schemas.LoginResponse)
def login(payload: dict, session: Session = Depends(db.get_db)):
    user_data = payload.get("input")
    if not user_data:
        raise HTTPException(status_code=400, detail="Missing input payload")

    email = user_data.get("email")
    password = user_data.get("password")

    stmt = select(models.User).where(models.User.email == email)  # type: ignore
    db_user = session.execute(stmt).scalars().first()
    if not db_user or not auth.verify_password(password, db_user.password_hash):
        return {"success": False, "message": "Invalid credentials", "token": None}

    token = auth.create_jwt(str(db_user.id))
    return {"success": True, "message": "Login successful", "token": token}
