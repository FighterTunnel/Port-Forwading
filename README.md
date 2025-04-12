# API Documentation

This document provides an overview of the available API endpoints in the application, along with their authentication requirements and example responses.

## API Endpoints

1. **GET /portforwarding/list**
   - **Description**: Lists all port forwardings.
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /portforwarding/list?token=ADMIN_TOKEN`
   - **Response**:
     ```json
     {
       "success": true,
       "vps_forwardings": [...],
       "local_configs": [...],
       "mismatch_count": 0,
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

2. **GET /portforwarding/toggle**
   - **Description**: Toggles port forwarding for a specific user.
   - **Parameters**: `username`, `enable` (true/false)
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /portforwarding/toggle?token=ADMIN_TOKEN&username=testuser&enable=true`
   - **Response**:
     ```json
     {
       "success": true,
       "results": [...],
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

3. **GET /listethernet**
   - **Description**: Lists all ethernet interfaces.
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /listethernet?token=ADMIN_TOKEN`
   - **Response**:
     ```json
     {
       "success": true,
       "interfaces": [...],
       "modem_interface": {...},
       "default_interface": "eth0",
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

4. **GET /create**
   - **Description**: Creates a new user.
   - **Parameters**: `username`, `password`, `port`
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /create?token=ADMIN_TOKEN&username=testuser&password=testpass&port=12345`
   - **Response**:
     ```json
     {
       "success": true,
       "message": "User config created and service started",
       "filename": "testuser_eth0.yml",
       "data": {...},
       "service_running": true,
       "pid": 1234,
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

5. **GET /running**
   - **Description**: Lists all running services.
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /running?token=ADMIN_TOKEN`
   - **Response**:
     ```json
     {
       "success": true,
       "running_services": [...],
       "count": 5,
       "api_managed_count": 3,
       "externally_managed_count": 2,
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

6. **GET /deleteuser**
   - **Description**: Deletes a user.
   - **Parameters**: `username`
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /deleteuser?token=ADMIN_TOKEN&username=testuser`
   - **Response**:
     ```json
     {
       "success": true,
       "message": "Operation completed",
       "results": [...],
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

7. **GET /listuser**
   - **Description**: Lists all users.
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /listuser?token=ADMIN_TOKEN`
   - **Response**:
     ```json
     {
       "success": true,
       "count": 10,
       "users": [...],
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

8. **GET /rotate**
   - **Description**: Rotates the modem IP for a user.
   - **Authentication**: Requires user token.
   - **Example**: `GET /rotate?token=USER_TOKEN`
   - **Response**:
     ```json
     {
       "success": true,
       "message": "Network mode changed from Auto to 4G Only",
       "details": {
         "modem_ip": "192.168.1.1",
         "previous_mode": "00",
         "new_mode": "03"
       },
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

9. **GET /portforwarding/modem**
   - **Description**: Adds modem port forwarding for a specified port.
   - **Parameters**: `port`
   - **Authentication**: Requires `ADMIN_TOKEN`.
   - **Example**: `GET /portforwarding/modem?token=ADMIN_TOKEN&port=12345`
   - **Response**:
     ```json
     {
       "success": true,
       "message": "Modem port forwarding added",
       "data": {...},
       "timestamp": "2023-10-10T12:00:00Z"
     }
     ```

10. **GET /portforwarding/delmodem**
    - **Description**: Deletes modem port forwarding for a specified port.
    - **Parameters**: `port`
    - **Authentication**: Requires `ADMIN_TOKEN`.
    - **Example**: `GET /portforwarding/delmodem?token=ADMIN_TOKEN&port=12345`
    - **Response**:
      ```json
      {
        "success": true,
        "message": "Modem port forwarding deleted",
        "data": {...},
        "timestamp": "2023-10-10T12:00:00Z"
      }
      ```

## Prerequisites

- Node.js and npm installed on your system.
- Ensure you have the necessary permissions to access the network interfaces and manage processes.


## License

This project is licensed under the MIT License - see the LICENSE file for details.
