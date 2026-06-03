import 'reflect-metadata'
import { NestFactory } from '@nestjs/core'
import { FastifyAdapter, type NestFastifyApplication } from '@nestjs/platform-fastify'
import cors from '@fastify/cors'
import { AppModule } from './app.module.js'
import { getConfig } from './config.js'

const bootstrap = async () => {
  const config = getConfig()
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter(),
  )

  await app.register(cors, {
    origin: config.corsOrigin,
  })

  await app.listen(config.port, config.host)
}

void bootstrap()
