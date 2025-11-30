"""
Configuration Celery pour le service de transaction
"""

from celery import Celery
import os

# Configuration Redis
REDIS_URL = os.getenv('REDIS_URL', 'redis://localhost:6379/0')

# Créer l'application Celery
celery_app = Celery(
    'transaction_service',
    broker=REDIS_URL,
    backend=REDIS_URL,
    include=['transaction_service.tasks']
)

# Configuration Celery
celery_app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    enable_utc=True,
    task_track_started=True,
    task_time_limit=30 * 60,  # 30 minutes
    task_soft_time_limit=25 * 60,  # 25 minutes
    worker_prefetch_multiplier=1,
    worker_max_tasks_per_child=1000,
)

