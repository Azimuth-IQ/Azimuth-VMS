# Volunteer Management & PDF Generator

This project is a Volunteer Management System built with FastAPI. It allows for managing volunteer data, generating filled PDF forms, and handling batch uploads via Excel. It also includes tools for analyzing PDF forms using Google Document AI.

## Features

- **Volunteer Management:** Add, edit, and list volunteers.
- **PDF Generation:** Automatically fill a specific PDF form ("الاستمارة الجديدة الدائمية.pdf") with volunteer data.
- **Photo Handling:** Upload and embed volunteer photos into the generated PDF.
- **Batch Processing:** Upload multiple volunteers at once using an Excel template.
- **QR Code Generation:** Generate QR codes linking to volunteer profiles.
- **Arabic Text Support:** Correctly handles Arabic text reshaping and directionality in PDFs.
- **PDF Analysis:** Includes a script (`analyze_with_docai.py`) to analyze PDF form fields using Google Document AI.

## Tech Stack

- **Framework:** FastAPI
- **Database:** SQLAlchemy (SQLite by default)
- **PDF Engine:** PyMuPDF (fitz)
- **Templating:** Jinja2
- **Data Processing:** Pandas, OpenPyXL
- **Cloud Integration:** Google Cloud Document AI (for development/analysis)

## Project Structure

```
.
├── app/
│   ├── main.py            # Application entry point and API routes
│   ├── models.py          # Database models
│   ├── database.py        # Database connection
│   ├── pdf_service.py     # PDF generation logic
│   └── templates/         # HTML templates
├── assets/                # Static assets (PDF templates, keys)
├── generated_pdfs/        # Output directory for generated PDFs
├── uploads/               # Directory for uploaded photos
├── analyze_with_docai.py  # Script to analyze PDF fields
├── requirements.txt       # Python dependencies
└── README.md              # Project documentation
```

## Setup & Installation

1.  **Clone the repository** (if applicable) or navigate to the project directory.

2.  **Install Dependencies:**

    ```bash
    pip install -r requirements.txt
    ```

3.  **Environment Setup:**
    - Ensure the `assets` folder contains the PDF template: `الاستمارة الجديدة الدائمية.pdf`.
    - (Optional) For `analyze_with_docai.py`, set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to your Google Cloud service account key path.

## Running the Application

Start the server using Uvicorn:

```bash
uvicorn app.main:app --reload
```

The application will be available at `http://127.0.0.1:8000`.

## Usage

1.  **Home Page:** View the list of volunteers.
2.  **New Volunteer:** Click "New" to add a volunteer manually. You can upload a photo or capture one if supported.
3.  **Edit:** Click on a volunteer to edit their details.
4.  **Generate PDF:** Click the PDF icon/link for a volunteer to generate and download their filled form.
5.  **Batch Upload:** Go to the "Batch" page to upload an Excel file with volunteer data.

## Development Tools

### PDF Analysis

To analyze the PDF form fields and map them to text labels using Google Document AI:

1.  Set up your Google Cloud credentials.
2.  Run the script:
    ```bash
    python analyze_with_docai.py
    ```
    This will generate/update `field_mapping.json` with the detected field mappings.
