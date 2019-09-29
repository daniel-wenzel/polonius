# Token Explore

Simple explorer of the ERC20 token network. Based on: https://github.com/cdimascio/generator-express-no-stress-typescript

## Quick Start

1. Copy the database to `../db/baltasar.db`
2. Install Dependencies
```shell
npm install
```
3. Start the application
```
npm run dev
```
4. Explore an address. For example the BAT User Growth Reserve: [http://localhost:3000/address/0x7c31560552170ce96c4a7b018e93cddc19dc61b6](http://localhost:3000/address/0x7c31560552170ce96c4a7b018e93cddc19dc61b6)
5. Navigate around by clicking on other nodes in the graph or by replacing the address in the url.

## Architecture

Simple Node.js app writting in TypeScript. Its routers can be found under `server/api/controllers/address`, the logic for database communication is unter `server/db/sql/`. **It uses a SQLite Database. With this database and due to the absense of a caching layer this app is not suited as an open web server.**