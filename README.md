# Flask Portfolio App

A personal portfolio website built with Flask, featuring user authentication, a guestbook commenting system, and deployment to Azure Container Apps via GitHub Actions.

![Python](https://img.shields.io/badge/Python-3.12-blue)
![Flask](https://img.shields.io/badge/Flask-3.1.3-green)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)
![Azure](https://img.shields.io/badge/Azure-Container%20Apps-blue)

## Features

- **Portfolio Pages**: Home, About, and Projects showcasing skills and experience
- **User Authentication**: Registration and login system using Flask-Login
- **Guestbook**: Commenting system for authenticated users with SQLite persistence
- **Responsive Design**: Clean, modern UI with custom CSS
- **Dockerized**: Ready for containerized deployment
- **CI/CD Pipeline**: Automated deployment via GitHub Actions to Azure Container Apps

## Tech Stack

- **Backend**: Python 3.12, Flask 3.1.3, Flask-SQLAlchemy, Flask-Login
- **Database**: SQLite
- **Server**: Gunicorn
- **Containerization**: Docker
- **Cloud**: Azure Container Apps
- **CI/CD**: GitHub Actions

## Project Structure

```
flask_app_portfolio/
├── app.py                  # Main Flask application
├── requirements.txt        # Python dependencies
├── dockerfile              # Docker configuration
├── docker-compose.yml      # Docker Compose for local development
├── manage.sh               # Management scripts
├── backup_db.sh            # Database backup script
├── azure-pipelines.yml     # Azure DevOps pipeline (legacy)
├── .github/
│   └── workflows/
│       └── deploy.yml      # GitHub Actions CI/CD pipeline
├── static/
│   └── style.css           # Custom styles
├── templates/              # HTML templates
│   ├── base.html
│   ├── home.html
│   ├── about.html
│   ├── projects.html
│   ├── guestbook.html
│   ├── login.html
│   └── register.html
├── instance/               # SQLite database directory
└── logs/                   # Application logs
```

## Getting Started

### Prerequisites

- Python 3.12+
- Docker (optional)
- Azure CLI (for deployment)

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/zaidlaz/flask_app_portfolio.git
   cd flask_app_portfolio
   ```

2. **Create a virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application**
   ```bash
   python app.py
   ```

5. **Access the app**
   Open your browser and navigate to `http://localhost:5004`

### Docker Deployment

1. **Build the Docker image**
   ```bash
   docker build -t flask-portfolio .
   ```

2. **Run the container**
   ```bash
   docker run -p 5004:5004 flask-portfolio
   ```

3. **Or use Docker Compose**
   ```bash
   docker-compose up
   ```

## Azure Deployment

This application is configured for automated deployment to Azure Container Apps via GitHub Actions.

### Required GitHub Secrets

Configure these secrets in your GitHub repository settings:

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Azure service principal JSON |
| `ACR_USERNAME` | Azure Container Registry username |
| `ACR_PASSWORD` | Azure Container Registry password |

### Azure Resources

- **Resource Group**: `rg-flask-portfolio`
- **Container Registry**: `zenecommerceacr123`
- **Container App**: `flask-app-portfolio`

### Manual Deployment

To trigger a deployment manually:
1. Go to the **Actions** tab in your GitHub repository
2. Select the **Build and Deploy to Azure Container Apps** workflow
3. Click **Run workflow**

## Application Routes

| Route | Description | Authentication |
|-------|-------------|----------------|
| `/` | Home page | No |
| `/about/` | About page | No |
| `/projects/` | Projects showcase | No |
| `/guestbook/` | Guestbook comments | Yes |
| `/login/` | User login | No |
| `/register/` | User registration | No |
| `/logout/` | User logout | Yes |

## Database Backup

A backup script is included for the SQLite database:

```bash
./backup_db.sh
```

Backups are stored in the `backups/` directory with timestamps.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SECRET_KEY` | Flask secret key | `change-this-secret-key` |
| `FLASK_ENV` | Flask environment | `production` |

## Author

**Zaid Lazim**
- LinkedIn: [linkedin.com/in/zaidlaz](https://www.linkedin.com/in/zaidlaz)
- GitHub: [github.com/zaidlaz](https://github.com/zaidlaz)
- Email: lazimzaid@yahoo.com.sg

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- Built as part of hands-on learning in Python, Linux, and DevOps
- Flask and Flask-Login for authentication framework
- Azure for cloud hosting infrastructure
