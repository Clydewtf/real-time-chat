from typing import Optional
from pydantic import BaseModel, EmailStr


class UserCreate(BaseModel):
    email: EmailStr
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class LoginResponse(BaseModel):
    success: bool
    message: str
    token: Optional[str]


class RegisterResponse(BaseModel):
    success: bool
    message: Optional[str]
    token: Optional[str]

    class Config:
        from_attributes = True
