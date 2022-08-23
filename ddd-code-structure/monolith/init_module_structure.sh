#!/bin/bash

# Interfaces / Inbound adaptors
mkdir -p module/interfaces/file
mkdir -p module/interfaces/rest
mkdir -p module/interfaces/socket
mkdir -p module/interfaces/web

# Application services / Application layer
mkdir -p module/application/internal/commands
mkdir -p module/application/internal/events
mkdir -p module/application/internal/queries
mkdir -p module/application/saga
mkdir -p module/application/transform

# Domain models / Domain layer
mkdir -p module/domain/aggregates
mkdir -p module/domain/entities
mkdir -p module/domain/valueobjects

# Infrastructure / Outbound adaptors
mkdir -p module/infrastructure/events
mkdir -p module/infrastructure/messaging
mkdir -p module/infrastructure/persistence

# Shared services
mkdir -p shared/infrastructure/events
