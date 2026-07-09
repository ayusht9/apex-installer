# Oracle APEX + ORDS Local Automated Setup

This repository contains a fully automated local environment for Oracle 19c Enterprise, Oracle APEX, and Oracle REST Data Services (ORDS).

## Prerequisites

1. **Docker and Docker Compose** installed.

## Getting Started

1. Clone or copy this repository to your laptop.
2. Verify the `.env` file
   (Feel free to modify the passwords in `.env` if desired).
3. Open a terminal and run:
   ```bash
   docker compose up -d
   ```

### What happens automatically?
- **`apex-extractor`**: A lightweight alpine container will automatically download the 250MB APEX installation zip directly from Oracle OTN if it doesn't already exist locally. It will then automatically extract the full package.
- **`oracle-db`**: The Oracle 19c Enterprise database will start up. Once created, it automatically runs the `setup-scripts-db/01_install_apex.sh` script, which:
  - Installs Oracle APEX inside the DB.
  - Configures APEX REST Endpoints.
  - Sets APEX Admin and PDBADMIN passwords based on your `.env` file.
  - **Note:** This DB installation phase takes ~10-15 minutes.
- **`ords`**: The ORDS web server waits via a Docker healthcheck for the APEX database installation to finish. Once the DB signals completion, ORDS boots, installs its schemas, automatically detects APEX, configures the APEX connection pools, maps the static images, and starts the server.

## Accessing APEX

Once the ORDS container is running, access the APEX environment at:
- **Workspace Admin**: [http://localhost:8080/ords/apex_admin](http://localhost:8080/ords/apex_admin)
- **SQL Developer Web**: [http://localhost:8080/ords/pdbadmin/_sdw/](http://localhost:8080/ords/pdbadmin/_sdw/)

Check the `credentials` file for the exact logins and passwords!

---

## Prompt for LLM Assistants

If you need to make changes to this setup on a new machine and want to hand it off to an LLM, provide it with the following prompt to get it up to speed immediately:

> "I have a Docker Compose setup running Oracle 19c Enterprise, ORDS, and APEX. The setup is fully automated:
> 1. Credentials are managed via an `.env` file containing `ORACLE_PWD` and `APEX_PWD`.
> 2. An init container (`apex-extractor`) automatically downloads `apex_24.1_en.zip` and extracts the full package to `./apex_install`.
> 3. The `oracle-db` container mounts `./setup-scripts-db` to `/opt/oracle/scripts/setup`. The DB automatically executes `01_install_apex.sh` during initialization, which installs APEX, configures REST, and writes a healthcheck flag file when done.
> 4. The `ords` container waits for the DB's healthcheck, and uses `APEX_PWD` to natively configure APEX connection pools upon installation.
> 
> Please keep this architecture in mind when suggesting any modifications or troubleshooting issues."
