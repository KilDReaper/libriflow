# LibriFlow TypeScript Integration Module

This folder contains a production-style TypeScript API integration layer for LibriFlow backend endpoints.

## Selected Frontend Stack

- Framework: React (web) / React Native compatible
- Language: TypeScript
- HTTP: Axios
- State management recommendation: Zustand
- UI recommendation: Material UI (web) or React Native Paper (mobile)

## Included

- Typed models and API contracts
- Axios client with interceptors
- JWT access/refresh token handling
- Automatic token refresh and request retry
- Service modules for auth, books/recommendations, reservations, borrowings, payments, and QR issuing

## Base URL

Set one of the following:

- `LIBRIFLOW_API_URL=http://localhost:5000/api`
- `LIBRIFLOW_API_URL=https://your-backend-domain.com/api`
