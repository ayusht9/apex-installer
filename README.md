# Oracle APEX + ORDS Local Automated Setup

This repository contains a fully automated local environment for Oracle Database Free, Oracle APEX, and Oracle REST Data Services (ORDS).

## Prerequisites

1. **Docker and Docker Compose** installed.
2. The APEX installation zip file: `apex_26.1_en.zip` must be present in the root of this directory.

## Getting Started

1. Clone or copy this repository to your laptop.
2. Ensure the `apex_26.1_en.zip` file is located in the same directory as `docker-compose.yml`.
3. Open a terminal and run:

   ```bash
   docker compose up -d
   ```

### What happens automatically?
- **`apex-extractor`**: A lightweight alpine container will automatically unzip the required APEX static images from the zip file.
- **`oracle-db`**: The Oracle 23c Free database will start up.
- **`ords`**: The ORDS web server will wait for the extraction to finish and the database to start. Upon startup, it will:
  - Generate its configuration automatically.
  - Automatically map the extracted static APEX images (`/i/`).
  - Automatically run `setup-scripts/01_enable_rest.sh` to REST-enable the `PDBADMIN` user.

## Accessing APEX

Once the containers are healthy, access the APEX environment at:
[http://localhost:8080/ords/pdbadmin/_sdw/](http://localhost:8080/ords/pdbadmin/_sdw/)

**Login Details:**
- **Path:** `pdbadmin`
- **Username:** `PDBADMIN`
- **Password:** `Oracle1234`

---

## Prompt for LLM Assistants

If you need to make changes to this setup on a new machine and want to hand it off to an LLM, provide it with the following prompt to get it up to speed immediately:

> "I have a Docker Compose setup running Oracle Database Free, ORDS, and APEX. The setup is fully automated:
> 1. An init container (`apex-extractor`) unzips `apex_26.1_en.zip` to `./apex_install` so static images can be served by ORDS.
> 2. The ORDS container mounts `./setup-scripts:/ords-entrypoint.d` which contains a script (`01_enable_rest.sh`) that dynamically runs SQLcl to REST-enable the `PDBADMIN` schema on startup.
> 3. ORDS automatically detects `/opt/oracle/apex/images` and configures `standalone.static.path`.
> 
> My `docker-compose.yml` mounts the DB volume and the ORDS config volume to persist data across restarts. Please keep this architecture in mind when suggesting any modifications or troubleshooting issues."
