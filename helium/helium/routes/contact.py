from fastapi import APIRouter, HTTPException, Body, Depends
from typing import List
from sqlalchemy.orm import Session

# Assuming these schemas are defined as above
from helium.schemas.contact import ContactCreate, ContactSchema, ContactOut, ContactResponse, MessageResponse
from helium.db import get_read_db, get_write_db
from helium.crud.contact import (
    _list_contacts,
    _create_contact,
    _find_contact_by_id,
    _update_contact,
    _delete_contact,
)

router = APIRouter()

# GET route for listing contacts
@router.get("/list", response_model=List[ContactOut])
async def list_contacts(db: Session = Depends(get_read_db)):
    result = await _list_contacts(db)
    return result or []

# POST route for creating a contact
@router.post("/create", response_model=ContactResponse, status_code=201)
async def create_contact(contact: ContactCreate = Body(...), db: Session = Depends(get_write_db)):
    created_contact = await _create_contact(db, contact)
    return created_contact

# GET route for reading a specific contact by ID
@router.get("/read/{contact_id}", response_model=ContactOut)
async def read_contact(contact_id: int, db: Session = Depends(get_read_db)):
    result = await _find_contact_by_id(db, contact_id)
    if not result:
        raise HTTPException(status_code=404, detail="Contact not found")
    return result

# PUT or PATCH route for updating a contact
@router.put("/update/{contact_id}", response_model=MessageResponse)
async def update_contact(contact_id: int, db: Session = Depends(get_write_db), contact_data: ContactSchema = Body(...)):
    updated_count = await _update_contact(db, contact_id, contact_data.dict())
    if updated_count == 0:
        raise HTTPException(status_code=404, detail="Contact not found")
    
    return {"message": "Contact updated successfully."}

# DELETE route for deleting a contact
@router.delete("/delete/{contact_id}", response_model=MessageResponse)
async def delete_contact(contact_id: int, db: Session = Depends(get_write_db)):
    deleted_count = await _delete_contact(db, contact_id)
    if deleted_count == 0:
        raise HTTPException(status_code=404, detail="Contact not found")
    
    return {"message": "Contact deleted successfully."}
