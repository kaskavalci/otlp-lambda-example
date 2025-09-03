import { metrics } from '@opentelemetry/api';

const meter = metrics.getMeter('otlp-lambda-example');

const counter = meter.createCounter('otlp-lambda-example.counter', {
    description: 'A counter for the otlp-lambda-example',
    unit: 'count',
});

// Lambda handler
const handler = async (): Promise<void> => {
    console.log('Adding 1 to the counter');
    counter.add(1);

    const meterProvider = metrics.getMeterProvider();

    if (process.env.FLUSH_METRICS === 'forceFlush') {
        try {
            console.log('Force flushing metrics...');
            await meterProvider.forceFlush();
            console.log('Successfully flushed metrics using shutdown');
        } catch (error) {
            console.error('Failed to flush metrics', { error });
        }
    } else if (process.env.FLUSH_METRICS === 'shutdown') {
        try {
            console.log('Shutting down metrics...');
            await meterProvider.shutdown();
            console.log('Successfully flushed metrics using shutdown');
        } catch (error) {
            console.error('Failed to shutdown collector', { error });
        }
    } else {
        console.log('Otel lambda layers will flush metrics automatically');
    }
};

// CommonJS export
module.exports = { handler };
