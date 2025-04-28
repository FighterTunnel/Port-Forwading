# API Documentation

This project provides a REST API to manage system, users, modems, backups, SMS, and network interfaces.

## Endpoints

### Interfaces
- `GET /api/interfaces`  
  _Replaces_: `list-interfaces`

### Users
- `GET /api/users`  
  _Replaces_: `list-users`
- `GET /api/users/:username/details`  
  _Replaces_: `check <username>`
- `POST /api/users`  
  _Replaces_: `create`
- `POST /api/users/sync`  
  _Replaces_: `sync`
- `DELETE /api/users/:username`  
  _Replaces_: `delete <username>`
- `POST /api/users/:username/expiration`  
  _Replaces_: `set-expiration`
- `GET /api/users/expired`  
  _Replaces_: `check-expired`
- `POST /api/users/:username/port-forward`  
  _Replaces_: `port-forward`
- `POST /api/users/:username/rotate-modem`  
  _Replaces_: `rotate <username>`
- `PUT /api/users/:username/interface`  
  _Replaces_: `switch-interface`
- `PUT /api/users/:username/ip-type`  
  _Replaces_: `switch-ip-type`
- `POST /api/users/:username/suspend`  
  _Replaces_: `suspend`
- `POST /api/users/:username/unsuspend`  
  _Replaces_: `unsuspend`
- `POST /api/users/:username/expire`  
  _Replaces_: `expire`

### System
- `GET /api/system/status`  
  _Replaces_: `system-status`
- `GET /api/system/summary`  
  _Replaces_: `check (no args)`
- `GET /api/system/device-info`  
  _Replaces_: `device-info`
- `GET /api/system/traffic-info`  
  _Replaces_: `traffic-info`
- `POST /api/system/rotate-public`  
  _Replaces_: `rotate-public`
- `POST /api/system/sync-eth`  
  _Replaces_: `sync-eth`

### Modems
- `GET /api/modems` or `GET /api/modems/:interface`  
  _Replaces_: `modem-info [interface]`

### SMS
- `GET /api/sms/:interface`  
  _Replaces_: `sms list <interface>`
- `POST /api/sms`  
  _Replaces_: `sms send`
- `DELETE /api/sms/:interface/:index`  
  _Replaces_: `sms delete <interface> <index>`

### Backups
- `POST /api/backups`  
  _Replaces_: `backup create`
- `GET /api/backups`  
  _Replaces_: `backup list`
- `POST /api/backups/restore`  
  _Replaces_: `backup restore <backupName>`

### Port Forwards
- `GET /api/port-forwards/check`  
  _Replaces_: `check-forwards`

### WireGuard
- `POST /api/wireguard/config`  
  _Replaces_: `add-wg`

## Existing (Unchanged) Endpoints
- `POST /api/get-admin-token`
- `POST /api/rotate-links`
- `GET /api/download-user-config`
- `POST /rotate`

---

## Notes
- Make sure to authenticate properly where required.
- Some endpoints require parameters (e.g., `:username`, `:interface`, etc.).



# API Documentation Via Bash Shell
This document provides a guide for using the `example.sh` script, which manages SOCKS5 proxy users, WireGuard configurations, and port forwarding. Below are the available commands, their usage, and example responses.

## Available Commands

1. **Create User**: `./example.sh create <username> <password> <port> <interface> <address_type> [port_forwarding]`
2. **List Users**: `./example.sh list`
3. **Check User**: `./example.sh check <username>`
4. **Sync Users**: `./example.sh sync`
5. **Delete User**: `./example.sh delete <username>`
6. **Toggle Port Forwarding**: `./example.sh port-forward <username> <true|false> [token]`
7. **Check VPS Forwards**: `./example.sh check-forwards <token> [port]`
8. **Add WireGuard**: `./example.sh add-wg <ipvps> [api_port] [token]`
9. **Rotate Modem**: `./example.sh rotate <username>`
10. **Switch Interface**: `./example.sh switch-interface <username> <new_interface>`
11. **Switch Address Type**: `./example.sh switch-ip-type <username> <ipv4|ipv6|unspec>`
12. **Rotate Public Port**: `./example.sh rotate-public <true|false> [token]`

## Example Responses



## Detailed Command Usage

### 1. Create User
Creates a new SOCKS5 proxy user.

**Example**:
```bash
./example.sh create user1 password1 20000 eth0 ipv4 false
```
### Successful Response
```json
{
  "status": "success",
  "message": "User created successfully",
  "timestamp": "2023-10-01 12:34:56",
  "data": {
    "username": "user1",
    "port": 20000,
    "interface": "eth0",
    "address_type": "ipv4",
    "port_forwarding": false,
    "service": "socks5@user1"
  },
  "details": {
    "config_path": "/root/users/user1.yml",
    "wireguard_ip": "10.66.66.1",
    "service_status": "active"
  }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Invalid username: only alphanumeric, dash and underscore characters allowed",
  "timestamp": "2023-10-01 12:34:56",
  "data": null,
  "details": {
    "validation_error": "invalid_characters",
    "allowed_characters": "a-zA-Z0-9_-"
  }
}
```
### 2. List Users
Lists all existing users and their details.

**Example**:
```bash
./example.sh list
```
### Successful Response
```
{"status":"success","message":"Found 2 users","timestamp":"2025-04-19 21:03:35","data":{
      "users": [{
  "username": "fest",
  "port": 1816,
  "address_type": "ipv4",
  "password": "",
  "status": "active",
  "service": "socks5@fest",
  "interface": "",
  "interface_ipv4": "",
  "interface_ipv6": "",
  "interface_link_local_ipv6": "",
  "port_forwarding": false,
  "service_details": {
    "active_state": "active",
    "sub_state": "running"
  },
  "last_logs": []
},{
  "username": "user2",
  "port": 21002,
  "address_type": "ipv6",
  "password": "",
  "status": "active",
  "service": "socks5@user2",
  "interface": "eth2",
  "interface_ipv4": "192.168.8.100",
  "interface_ipv6": "2400:9800:f9:16c1:baab:be34:0:2",
  "interface_link_local_ipv6": "fe80::7199:346a:2bdf:bbf0",
  "port_forwarding": true,
  "service_details": {
    "active_state": "active",
    "sub_state": "running"
  },
  "last_logs": ["[2025-04-19 07:28:21] [E] 0x7f94005d80 socks5 server connect","[2025-04-19 07:28:21] [E] 0x7f94005a40 socks5 server connect"]
}],
      "system": {
      "total_users": 2,
      "total_interfaces": 3,
      "modem_interface": "eth1",
      "modem_ip": "192.168.9.1",
      "wireguard_interface": "wg0",
      "wireguard_ipv4": "10.66.66.2",
      "wireguard_ipv6": "fd42:42:42::2",
      "interfaces": [{
          "name": "eth0",
          "type": ""regular"",
          "ipv4": "192.168.1.67",
          "ipv6": "",
          "link_local_ipv6": "fe80::ce51:1dd2:f7f6:b738"
        },{
          "name": "eth1",
          "type": ""modem"",
          "ipv4": "192.168.9.100",
          "ipv6": "",
          "link_local_ipv6": "fe80::2929:ba2e:4c86:6f28"
        },{
          "name": "eth2",
          "type": ""regular"",
          "ipv4": "192.168.8.100",
          "ipv6": "2400:9800:f9:16c1:baab:be34:0:2",
          "link_local_ipv6": "fe80::7199:346a:2bdf:bbf0"
        }]}
    },"details":{"users_dir":"/root/users","file_count":2}}
```
### 3. Check User
Checks the details of a specific user.

**Example**:
```bash
./example.sh check user1
```

### 4. Sync Users
Restarts all user services to apply changes.

**Example**:
```bash
./example.sh sync
```

### 5. Delete User
Deletes a user and their configuration.

**Example**:
```bash
./example.sh delete user1
```

### 6. Toggle Port Forwarding
Enables or disables port forwarding for a user.

**Example**:
```bash
./example.sh port-forward user1 true 9daef93138f010cd94990d61e5954e205051b6ab9db0cbfdbfb9e01f5ebe3868
```

### 7. Check VPS Forwards
Checks if a port is already forwarded on the VPS.

**Example**:
```bash
./example.sh check-forwards 9daef93138f010cd94990d61e5954e205051b6ab9db0cbfdbfb9e01f5ebe3868 20000
```

### 8. Add WireGuard
Adds a WireGuard configuration for local routes.

**Example**:
```bash
./example.sh add-wg 192.168.1.100 8080 9daef93138f010cd94990d61e5954e205051b6ab9db0cbfdbfb9e01f5ebe3868
```

### 9. Rotate Modem
Rotates the modem interface for a user.

**Example**:
```bash
./example.sh rotate user1
```

### 10. Switch Interface
Switches the interface for a user.

**Example**:
```bash
./example.sh switch-interface user1 eth1
```

### 11. Switch Address Type
Switches the address type (IPv4/IPv6) for a user.

**Example**:
```bash
./example.sh switch-ip-type user1 ipv6
```

### 12. Rotate Public Port
Enables or disables public port rotation.

**Example**:
```bash
./example.sh rotate-public true 9daef93138f010cd94990d61e5954e205051b6ab9db0cbfdbfb9e01f5ebe3868
```

## Notes
- Ensure the script has executable permissions: `chmod +x example.sh`.
- The `token` parameter is optional for some commands but required for operations involving the VPS API.
- Logs are stored in `/root/users/logs/` for debugging purposes. 


# API Documentation VIA URL

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
