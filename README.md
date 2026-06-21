# Oracle APEX + ORDS Local Automated Setup

This repository contains a fully automated local environment for Oracle Database Free, Oracle APEX, and Oracle REST Data Services (ORDS).

## Prerequisites

1. **Docker and Docker Compose** installed.

## Getting Started

1. Clone or copy this repository to your laptop.
2. Create a `.env` file by copying the provided example:
   ```bash
   cp .env.example .env
   ```
   (Feel free to modify the passwords in `.env` if desired).
3. Open a terminal and run:
   ```bash
   docker compose up -d
   ```

### What happens automatically?
- **`apex-extractor`**: A lightweight alpine container will automatically download the 250MB APEX installation zip directly from Oracle OTN if it doesn't already exist locally. It will then automatically extract the required static images.
- **`oracle-db`**: The Oracle 23c Free database will start up.
- **`ords`**: The ORDS web server will wait for the extraction to finish and the database to start. Upon startup, it will:
  - Generate its configuration automatically.
  - Automatically map the extracted static APEX images (`/i/`).
  - Automatically run `setup-scripts/01_enable_rest.sh` using your `.env` credentials to REST-enable the `PDBADMIN` user.

## Accessing APEX

Once the containers are healthy, access the APEX environment at:
[http://localhost:8080/ords/pdbadmin/_sdw/](http://localhost:8080/ords/pdbadmin/_sdw/)

Check the `credentials` file for the exact logins and passwords!

---

## Prompt for LLM Assistants

If you need to make changes to this setup on a new machine and want to hand it off to an LLM, provide it with the following prompt to get it up to speed immediately:

> "I have a Docker Compose setup running Oracle Database Free, ORDS, and APEX. The setup is fully automated:
> 1. Credentials are managed via an `.env` file.
> 2. An init container (`apex-extractor`) automatically downloads `apex_26.1_en.zip` from Oracle and unzips it to `./apex_install` so static images can be served by ORDS.
> 3. The ORDS container mounts `./setup-scripts:/ords-entrypoint.d` which contains a script (`01_enable_rest.sh`) that dynamically runs SQLcl using `.env` variables to REST-enable the `PDBADMIN` schema on startup.
> 4. ORDS automatically detects `/opt/oracle/apex/images` and configures `standalone.static.path`.
> 
> My `docker-compose.yml` mounts the DB volume and the ORDS config volume to persist data across restarts. Please keep this architecture in mind when suggesting any modifications or troubleshooting issues."
