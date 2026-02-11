# Logging Pipeline with Fluent Bit and OpenSearch

This setup demonstrates a complete logging pipeline using Docker Compose with:
- Example Node.js application (generates logs to stdout)
- Fluent Bit (log collector and forwarder)
- OpenSearch (search and analytics engine)
- OpenSearch Dashboards (visualization UI)

If you need help, please feel free to contact us [here](https://starclustersolutions.com/contact/).

## Prerequisites

- Docker and Docker Compose installed
- At least 4GB of available RAM (OpenSearch requires memory)
- Ports available: 3000, 5601, 9200, 24224

## Directory Structure

```
.
├── docker-compose.yml
├── app/
│   ├── index.js
│   └── package.json
└── fluent-bit/
    ├── fluent-bit.conf
    └── parsers.conf
```

## Setup Instructions

### Step 1: Install Dependencies for the Example App

```bash
cd app
npm install
cd ..
```

### Step 2: Start All Services

```bash
docker-compose up -d
```

This will start:
- OpenSearch on port 9200
- OpenSearch Dashboards on port 5601
- Fluent Bit on port 24224
- Example app on port 3000

### Step 3: Verify Services Are Running

```bash
# Check all containers are up
docker-compose ps

# Check OpenSearch health
curl http://localhost:9200/_cluster/health?pretty

# View Fluent Bit logs
docker-compose logs -f fluent-bit
```

Press Ctrl+C twice to exit logs view.


### Step 4: View Application Logs

```bash
# View example app logs
docker-compose logs -f example-app
```

Press Ctrl+C twice to exit logs view.



## Using the System

### Generate Different Log Types

The example app exposes several endpoints:

```bash
# Generate INFO logs
curl http://localhost:3000/

# Generate ERROR logs
curl http://localhost:3000/error

# Generate WARNING logs
curl http://localhost:3000/warn
```

The app also generates periodic logs every 5 seconds automatically.

### Access OpenSearch Dashboards

1. Open your browser and go to: http://localhost:5601
2. Wait for OpenSearch Dashboards to initialize (may take 1-2 minutes)

### Create Index Pattern in OpenSearch Dashboards

1. Click on "Hamburger menu" (☰) → Dashboard Management → Index Pattern.
2. Click "Create index pattern"
4. Enter index pattern: `app-logs-*`
5. Click "Next step"
6. Select time field: `@timestamp`
7. Click "Create index pattern"

This process tells Dashboards which indices to query and how to interpret their fields. It's just a UI configuration layer - it doesn't move or store data, just defines what to search and which field is the timestamp.

OpenSearch node app has already indexed the logs.

### View Logs in Discover

1. Click on "Hamburger menu" (☰) → Discover
2. You should see your application logs appearing in real-time
3. You can filter by fields like:
   - `level` (info, error, warn, debug)
   - `message`
   - `service`
   - `method` (for HTTP requests)
4. Try searching for keywords like `debug`, `info` and `warn`. 


## How It Works

### Log Flow

```
Example App (stdout)
    ↓
Fluent Bit (collector)
    ↓
OpenSearch (storage) 
    ↓
Dashboards (visualization)
```

1. **Example App**: Writes JSON-formatted logs to stdout
2. **Fluent Bit**: 
   - Receives logs via Forward protocol (Docker logging driver)
   - Parses JSON logs
   - Forwards to OpenSearch with Logstash format
3. **OpenSearch**: Indexes logs for searching and analysis
4. **Dashboards**: Provides UI for querying and visualizing logs

### Configuration Details

**Fluent Bit (`fluent-bit.conf`):**
- INPUT: Listens on port 24224 for log forwarding
- FILTER: Parses JSON logs from Docker
- OUTPUT: Sends to OpenSearch with daily indices (app-logs-YYYY.MM.DD)

**Docker Logging:**
- Example app uses `fluentd` logging driver
- Sends all stdout/stderr to Fluent Bit

**OpenSearch:**
- Security disabled for simplicity (don't use in production!)
- Single-node setup
- Stores data in Docker volume

## Troubleshooting

### No logs appearing in OpenSearch

1. Check Fluent Bit is receiving logs:
   ```bash
   docker-compose logs fluent-bit
   ```

2. Check if indices are being created:
   ```bash
   curl http://localhost:9200/_cat/indices?v
   ```

3. Restart the example app:
   ```bash
   docker-compose restart example-app
   ```

### Dashboards not loading

Wait 1-2 minutes after starting services. OpenSearch Dashboards needs time to initialize.

### OpenSearch won't start (vm.max_map_count error)

On Linux, you may need to increase vm.max_map_count:

```bash
sudo sysctl -w vm.max_map_count=262144
```

To make it permanent, add to `/etc/sysctl.conf`:
```
vm.max_map_count=262144
```



## Stopping and Cleaning Up

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (deletes all logs)
docker-compose down -v
```

## Production Considerations

For production use, you should:

1. **Enable OpenSearch security** (TLS, authentication)
2. **Use proper resource limits** in docker-compose.yml
3. **Configure log retention policies** (Index Lifecycle Management)
4. **Set up multi-node OpenSearch cluster** for high availability
5. **Use secrets management** for credentials
6. **Configure proper log rotation** in Fluent Bit
7. **Add monitoring** for the logging pipeline itself
8. **Secure Fluent Bit** with TLS when forwarding logs

## Customization

### Modify Log Format

Edit `app/index.js` to change the log structure:

```javascript
console.log(JSON.stringify({
  timestamp: new Date().toISOString(),
  level: 'info',
  // Add your custom fields here
  customField: 'value'
}));
```

### Add More Inputs to Fluent Bit

Edit `fluent-bit/fluent-bit.conf` to add more input sources:

```ini
[INPUT]
    Name   tail
    Path   /var/log/*.log
    Parser json
```

### Modify OpenSearch Index Settings

You can create index templates to control mappings and settings:

```bash
curl -X PUT "http://localhost:9200/_index_template/app-logs-template" \
  -H 'Content-Type: application/json' \
  -d '{
    "index_patterns": ["app-logs-*"],
    "template": {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
      }
    }
  }'
```

## Additional Resources

- [Fluent Bit Documentation](https://docs.fluentbit.io/)
- [OpenSearch Documentation](https://opensearch.org/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
