def edit_word_doc(value_dict, value_dic):
    # Open the document template
    doc = Document('./output.docx')
    
    # Replace placeholders in paragraphs
    for paragraph in doc.paragraphs:
        for run in paragraph.runs:
            print(f"Run text: {run.text}")


    
    # Replace placeholders in tables
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for key, value in value_dic.items():
                    if key in cell.text:
                        cell.text = cell.text.replace(key, value)
    
    # Save the edited document
    output_path = os.path.abspath('output.docx')
    doc.save(output_path)
    
    # Print the edited document
    print_word_doc(output_path)