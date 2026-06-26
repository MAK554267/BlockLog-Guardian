import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from web3 import Web3
import asyncio

class BlockchainMonitorConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_group_name = 'blockchain_monitor'
        
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()
        
        # Start monitoring
        self.monitoring_task = asyncio.create_task(self.monitor_blockchain())
    
    async def disconnect(self, close_code):
        if hasattr(self, 'monitoring_task'):
            self.monitoring_task.cancel()
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )
    
    async def receive(self, text_data):
        data = json.loads(text_data)
        if data.get('type') == 'ping':
            await self.send(text_data=json.dumps({'type': 'pong'}))
    
    async def monitor_blockchain(self):
        w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))
        last_block = 0
        
        while True:
            try:
                current_block = w3.eth.block_number
                
                if current_block > last_block:
                    # Send new block notification
                    await self.channel_layer.group_send(
                        self.room_group_name,
                        {
                            'type': 'new_block',
                            'block_number': current_block,
                            'timestamp': str(w3.eth.get_block(current_block).timestamp)
                        }
                    )
                    last_block = current_block
                
                # Check for new transactions
                pending = w3.eth.get_block_transaction_count('pending')
                if pending > 0:
                    await self.channel_layer.group_send(
                        self.room_group_name,
                        {
                            'type': 'pending_transactions',
                            'count': pending
                        }
                    )
                
                await asyncio.sleep(2)
            except Exception as e:
                await self.channel_layer.group_send(
                    self.room_group_name,
                    {
                        'type': 'error',
                        'message': str(e)
                    }
                )
                await asyncio.sleep(5)
    
    async def new_block(self, event):
        await self.send(text_data=json.dumps({
            'type': 'new_block',
            'block_number': event['block_number'],
            'timestamp': event['timestamp']
        }))
    
    async def pending_transactions(self, event):
        await self.send(text_data=json.dumps({
            'type': 'pending_transactions',
            'count': event['count']
        }))
    
    async def error(self, event):
        await self.send(text_data=json.dumps({
            'type': 'error',
            'message': event['message']
        }))
