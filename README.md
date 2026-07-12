# Oracle APEX + ORDS Local Automated Setup

This repository contains a fully automated local environment for Oracle 19c Enterprise, Oracle APEX, and Oracle REST Data Services (ORDS).

## Prerequisites

1. **Docker and Docker Compose** installed.

## Getting Started

1. Clone or copy this repository to your laptop.
2. Verify the `.env` file and create `conn_string.txt`
   (Copy `.env.example` to `.env`, and copy `conn_string.txt.example` to `conn_string.txt`. Feel free to modify the passwords if desired).
3. login in to `docker login container-registry.oracle.com`
4. Open a terminal and run:
   ```bash
   docker compose up -d
   ```

### What happens automatically?
- **`apex-extractor`**: A lightweight alpine container will automatically download the 250MB APEX installation zip directly from Oracle OTN if it doesn't already exist locally. It will then automatically extract the full package into a named Docker volume.
- **`oracle-db`**: The Oracle 19c Enterprise database will start up. Once created, it automatically runs the `setup-scripts-db/01_install_apex.sh` script, which:
  - Installs Oracle APEX inside the DB.
  - Configures APEX REST Endpoints.
  - Sets APEX Admin and PDBADMIN passwords based on your `.env` file.
  - Unlocks APEX proxy users (`APEX_PUBLIC_USER`, `APEX_REST_PUBLIC_USER`, `APEX_LISTENER`) for ORDS integration.
  - **Note:** This DB installation phase takes ~10-15 minutes.
- **`ords`**: The ORDS web server waits via a Docker healthcheck for the APEX database installation to finish. Once the DB signals completion, ORDS boots using your `conn_string.txt`, bypasses its internal version check via the `APEX_VER` environment variable, installs its schemas, automatically detects APEX, configures the APEX connection pools, maps the static images, and starts the server on port 8181 (mapped to host 8080).

## Accessing APEX

Once the ORDS container is running, access the APEX environment at:
- **Oracle APEX**: [http://localhost:8080/ords/apex](http://localhost:8080/ords/apex)
- **Workspace Admin**: [http://localhost:8080/ords/apex_admin](http://localhost:8080/ords/apex_admin)
- **SQL Developer Web**: [http://localhost:8080/ords/pdbadmin/_sdw/](http://localhost:8080/ords/pdbadmin/_sdw/)

Check the `credentials` file for the exact logins and passwords!

---

## Prompt for LLM Assistants

If you need to make changes to this setup on a new machine and want to hand it off to an LLM, provide it with the following prompt to get it up to speed immediately:

> "I have a Docker Compose setup running Oracle 19c Enterprise, ORDS 24.1, and APEX 24.1. The setup is fully automated:
> 1. Credentials are managed via an `.env` file containing `ORACLE_PWD` and `APEX_PWD`, as well as a `conn_string.txt` file containing the ORDS connection string.
> 2. An init container (`apex-extractor`) automatically downloads `apex_24.1_en.zip` and extracts the full package to a named Docker volume.
> 3. The `oracle-db` container mounts `./setup-scripts-db` to `/opt/oracle/scripts/setup`. The DB automatically executes `01_install_apex.sh` during initialization, which installs APEX, configures REST, unlocks APEX proxy users, and writes a healthcheck flag file when done.
> 4. The `ords` container waits for the DB's healthcheck. It mounts `conn_string.txt` to connect to the DB, uses `APEX_VER=24.1.0` to bypass internal version checks, and listens internally on port 8181 (mapped to host 8080).
> 
> Please keep this architecture in mind when suggesting any modifications or troubleshooting issues."
