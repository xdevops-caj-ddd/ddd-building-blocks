#!/bin/bash

# Interfaces / Inbound adaptors
mkdir -p microservice/interfaces/eventhandlers
mkdir -p microservice/interfaces/rest
mkdir -p microservice/interfaces/transform

# Application services / Application layer
mkdir -p microservice/application/internal/commandservices
mkdir -p microservice/application/internal/outboundservices
mkdir -p microservice/application/internal/queryservices

# Domain models / Domain layer
mkdir -p microservice/domain/model/aggregates
mkdir -p microservice/domain/model/commands
mkdir -p microservice/domain/model/entities
mkdir -p microservice/domain/model/events
mkdir -p microservice/domain/model/valueobjects

# Infrastructure / Outbound adaptors
mkdir -p microservice/infrastructure/repositories
mkdir -p microservice/infrastructure/brokers
mkdir -p microservice/infrastructure/configuration
