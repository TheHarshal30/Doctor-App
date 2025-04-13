import os
import sys
from docx import Document
import win32com.client as win32

def edit_word_doc(value_dict):
    # Open the document template
    doc = Document('./receipt.docx')
    
    # Replace placeholders with actual values
    for paragraph in doc.paragraphs:
        for key, value in value_dict.items():
            if key in paragraph.text:
            # Iterate over each run within the paragraph
                for run in paragraph.runs:
                    if key in run.text:
                        run.text = run.text.replace(key, value)

    
    # Save the edited document
    output_path = os.path.abspath('output.docx')
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
        '{CASENO}': sys.argv[1],
        '{NAME}': sys.argv[2],
        '{AGE}': sys.argv[3],
        '{DATE}': sys.argv[4],
        '{BILLNO}': sys.argv[5],
        '{DOC}': sys.argv[6],
        '{ADOC}': sys.argv[7],
    }
    
    # Edit and print the Word document
    edit_word_doc(value_dict)




