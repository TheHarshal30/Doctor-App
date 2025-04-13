import os
import sys
from docx import Document
import win32com.client as win32

def edit_word_doc(value_dict):
    # Open the document template
    doc = Document('./letter.docx')
    
    # Replace placeholders with actual values
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for key, value in value_dict.items():
                    if key in cell.text:
                        cell.text = cell.text.replace(key, value)

    
    # Save the edited document
    output_path = os.path.abspath('output2.docx')
    doc.save(output_path)
    
    # Print the edited document
    # print_word_doc(output_path)

def print_word_doc(doc_path):
    # Create a Word application instance
    word_app = win32.Dispatch('Word.Application')
    
    # Open the document
    doc = word_app.Documents.Open(doc_path)
    
    # Print the document
    doc.PrintOut()
    
    # Close the document without saving
    doc.Close(False)
    
    # Quit the Word application
    word_app.Quit()

if __name__ == "__main__":
    # Create a dictionary from command line arguments
    value_dict = {
        '{NAME}': sys.argv[1],
        '{AGE}': sys.argv[2],
        '{SEX}': sys.argv[3],
        '{ADDRESS}': sys.argv[4],
        '{CONTACT}': sys.argv[5],
        '{DOC}': sys.argv[6],
        '{DIAGNOSIS}': sys.argv[7],
    }
    
    # Edit and print the Word document
    edit_word_doc(value_dict)

