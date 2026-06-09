#!/bin/bash

for dir in adservice cartservice checkoutservice currencyservice emailservice frontend loadgenerator paymentservice productcatalogservice recommendationservice shippingservice shoppingassistantservice; do
    image="ghcr.io/sulav02/${dir}:v1.0.0"

    echo "Pushing $image..."

    docker push "$image"

    if [ $? -ne 0 ]; then
        echo "Failed to push $image"
        exit 1
    fi
done

echo "All images pushed successfully."
