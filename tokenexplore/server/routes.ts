import { Application } from 'express';
import examplesRouter from './api/controllers/examples/router'
import addressRouter from './api/controllers/address/'
export default function routes(app: Application): void {
  app.use('/api/v1/examples', examplesRouter);
  app.use('/address', addressRouter);
};