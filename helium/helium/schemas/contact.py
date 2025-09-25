from pydantic import BaseModel, Field, EmailStr

class ContactSchema(BaseModel):
    name: str
    email: EmailStr

class ContactCreate(ContactSchema):
    pass

class ContactOut(ContactSchema):
    id: int

    class Config:
        from_attributes = True
        populate_by_name = True

class ContactResponse(ContactSchema):
    id: int

class MessageResponse(BaseModel):
    message: str
