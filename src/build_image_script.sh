#!/bin/bash
for dir in adservice checkoutservice currencyservice emailservice frontend loadgenerator paymentservice productcatalogservice recommendationservice shippingservice shoppingassistantservice; do
    echo "Building Docker image for $dir..."

    docker build -t "ghcr.io/sulav02/${dir}:v1.0.0" "$dir"

    if [ $? -ne 0 ]; then
        echo "Failed to build $dir"
        exit 1
    fi
done
docker build -t ghcr.io/sulav02/cartservice:v1.0.0 src/cartservice/src/
echo "All images built successfully."
