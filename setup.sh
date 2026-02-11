#!/bin/bash

echo "================================"
echo "Logging Pipeline Setup Script"
echo "================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

echo "✓ Docker is running"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: docker-compose is not installed"
    exit 1
fi

echo "✓ docker-compose is available"
echo ""

# Install npm dependencies for the app
echo "📦 Installing app dependencies..."
cd app
if [ ! -d "node_modules" ]; then
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install npm dependencies"
        exit 1
    fi
    echo "✓ Dependencies installed"
else
    echo "✓ Dependencies already installed"
fi
cd ..

echo ""
echo "🚀 Starting services with Docker Compose..."
docker-compose up -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start services"
    exit 1
fi

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if OpenSearch is ready
echo "Checking OpenSearch..."
for i in {1..30}; do
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        echo "✓ OpenSearch is ready"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  OpenSearch is taking longer than expected to start"
    fi
    sleep 2
done

echo ""
echo "================================"
echo "✅ Setup Complete!"
echo "================================"
echo ""
echo "Services running:"
echo "  • OpenSearch:           http://localhost:9200"
echo "  • OpenSearch Dashboards: http://localhost:5601"
echo "  • Fluent Bit:           listening on port 24224"
echo "  • Example App:          running internally"
echo ""
echo "Next steps:"
echo "  1. Wait 1-2 minutes for OpenSearch Dashboards to fully initialize"
echo "  2. Open http://localhost:5601 in your browser"
echo "  3. Create an index pattern: 'app-logs-*'"
echo "  4. View logs in the Discover section"
echo ""
echo "Generate test logs:"
echo "  curl http://localhost:3000/"
echo "  curl http://localhost:3000/error"
echo "  curl http://localhost:3000/warn"
echo ""
echo "View logs:"
echo "  docker-compose logs -f example-app"
echo "  docker-compose logs -f fluent-bit"
echo ""
echo "Stop all services:"
echo "  docker-compose down"
echo ""
