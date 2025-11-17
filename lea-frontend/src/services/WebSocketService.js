class WebSocketService {
  constructor(url) {
    this.url = url;
    this.ws = null;
    this.reconnectAttempts = 0;
    this.maxReconnectAttempts = 5;
    this.reconnectDelay = 3000;
    this.onConnect = null;
    this.onDisconnect = null;
    this.onError = null;
    this.onMessage = null;
  }

  connect() {
    try {
      this.ws = new WebSocket(this.url);

      this.ws.onopen = () => {
        console.log('WebSocket connected');
        this.reconnectAttempts = 0;
        if (this.onConnect) {
          this.onConnect();
        }
      };

      this.ws.onclose = () => {
        console.log('WebSocket disconnected');
        if (this.onDisconnect) {
          this.onDisconnect();
        }
        this.attemptReconnect();
      };

      this.ws.onerror = (error) => {
        // Only log error if we're not in the process of reconnecting
        // This prevents spam when the server isn't ready yet
        if (this.reconnectAttempts === 0) {
          console.warn('WebSocket connection error (will retry):', error.type);
        }
        if (this.onError) {
          this.onError(error);
        }
      };

      this.ws.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data);
          if (this.onMessage) {
            this.onMessage(message);
          }
        } catch (error) {
          console.error('Error parsing WebSocket message:', error);
        }
      };
    } catch (error) {
      console.error('Error creating WebSocket:', error);
      if (this.onError) {
        this.onError(error);
      }
    }
  }

  attemptReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      // Only log reconnection attempts after the first one
      if (this.reconnectAttempts > 1) {
        console.log(`Attempting to reconnect (${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);
      }
      setTimeout(() => {
        this.connect();
      }, this.reconnectDelay);
    } else {
      console.error('Max reconnection attempts reached');
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }

  send(message) {
    if (this.ws && this.ws.readyState === WebSocket.OPEN) {
      this.ws.send(JSON.stringify(message));
    } else {
      console.error('WebSocket is not connected');
    }
  }
}

export default WebSocketService;

