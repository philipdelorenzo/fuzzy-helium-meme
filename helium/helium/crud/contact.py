from sqlalchemy.orm import Session
from sqlalchemy.future import select
from sqlalchemy import update, delete
from typing import List, Optional
from fastapi import HTTPException

# Assuming imports from your schemas and models files
from helium.models.contact import Contact
from helium.schemas.contact import ContactCreate

# --- CREATE ---
async def _create_contact(db: Session, contact: ContactCreate) -> Contact:
    """
    Creates a new contact with name and email.
    """
    existing_contact = await db.execute(
        select(Contact).where(
            (Contact.name == contact.name) | (Contact.email == contact.email)
        )
    )
    if existing_contact.scalars().first():
        raise HTTPException(status_code=400, detail="Contact with this name or email already exists.")
    
    new_contact = Contact(name=contact.name, email=contact.email)
    db.add(new_contact)
    await db.commit()
    await db.refresh(new_contact)
    
    return new_contact

# --- READ ---
async def _list_contacts(db: Session) -> List[Contact]:
    """
    Retrieves all contacts.
    """
    result = await db.execute(select(Contact).order_by(Contact.name))
    return result.scalars().all()


async def _find_contact_by_id(db: Session, contact_id: int) -> Optional[Contact]:
    """
    Finds a single contact by its unique ID.
    """
    result = await db.execute(select(Contact).where(Contact.id == contact_id))
    return result.scalars().first()

# --- UPDATE ---
async def _update_contact(db: Session, contact_id: int, contact_data: dict) -> int:
    """
    Updates an existing contact by its ID.
    """
    if "email" in contact_data:
        existing_email = await db.execute(select(Contact).where(Contact.email == contact_data["email"]))
        found_contact = existing_email.scalars().first()
        if found_contact and found_contact.id != contact_id:
            raise HTTPException(status_code=400, detail="Another contact with this email already exists.")
    
    query = update(Contact).where(Contact.id == contact_id).values(**contact_data)
    result = await db.execute(query)
    await db.commit()
    
    return result.rowcount

# --- DELETE ---
async def _delete_contact(db: Session, contact_id: int) -> int:
    """
    Deletes a contact by its ID.
    """
    query = delete(Contact).where(Contact.id == contact_id)
    result = await db.execute(query)
    await db.commit()
    
    return result.rowcount
