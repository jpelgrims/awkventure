import threading
import binascii
import hashlib
import socket
import select
import struct
import queue
import time
import sys
import io
import os
import re

PATH = os.path.dirname(os.path.realpath(__file__))

# Game server to handle multiple clients playing multiple games

class TcpClient:

    def __init__(self, connection, ip, port):
        self.id = id
        self.connection = connection
        self.ip = ip
        self.port = port
        self.buffer = ""
        self.command_sep = "\r\n"
        self.id = ip + str(port)
    
    def is_valid_command(self, command):
        return False

    def read_command(self):
        while not self.command_sep in self.buffer:
            message = self.connection.recv(2048).decode("unicode_escape")
            self.buffer += message
            pattern = "\\033\[([0-9]+);([0-9]+)R"
            match = re.match(pattern, message)
            if match:
                height, width = match.groups(0)
                re.sub(pattern, '', self.buffer)
                return  "RESIZE {0} {1}".format(str(width), str(height)) 
        command, *rest = self.buffer.split(self.command_sep)
        self.buffer = "".join(rest)
        if self.is_valid_command(command):
            return command
        else:
             return None
    
    def send_message(self, message):
        message = message + "\r\n"
        self.connection.sendall(message.encode("utf-8"))

    def quit(self):
        self.connection.close()


class PlayerClient(TcpClient):

    def __init__(self, connection, ip, port):
        super().__init__(connection, ip, port)
        self.type = "player"
        self.authenticated = False
        self.status = "menu"

    def draw_menu(self):
        message = "Awkventure online\n\n" \
                + "To register: REGISTER <name> <password>\n" \
                + "To login: LOGIN <name> <password>\n" \
                + "To play: PLAY <server_name>\n\n" \
                + "Playable servers:\n" \
                + "\tServer 1 - 0/20 players\n\n" \
                + " >"
        self.send_message(message)

    def set_char_mode(self):
        self.connection.sendall(b"\377\375\042\377\373\001")

    def get_console_size(self):
        self.connection.sendall(b'\033[s\033[999;999H\033[6n\033[u')
    
    def is_valid_command(self, command):
        pattern = ""
        if command.startswith("LOGIN"):
            pattern = "LOGIN\t[A-Za-z0-9_]+\t[A-Za-z0-9_]+"
        elif command.startswith("SIGNUP"):
            pattern = "REGISTER\t[A-Za-z0-9_]+\t[A-Za-z0-9_]+"
        else:
            return False
        
        return bool(re.search(pattern, command))

    def send_message(self, message):
        # dress up message here, draw interface
        message = "\033[2J" + "\033[H" + str(message)
        super().send_message(message)


class GameClient(TcpClient):

    def __init__(self, connection, ip, port):
        super().__init__(connection, ip, port)
        self.type = "game"


class Server:

    def __init__(self):
        self.config_file = os.path.join(PATH, "config.ini")
        self.config = self.__load_config()

        self.player_host = "127.0.0.1"
        self.player_port = 8888

        self.game_host = "127.0.0.1"
        self.game_port = 8887

        self.salt = "somesaltvaluereadfromconfigfile"
        self.accounts_file = os.path.join(PATH, "accounts.dat")
        self.accounts = self.__load_accounts()

        self.player_socket = self.__create_socket(self.player_host, self.player_port)
        self.game_socket = self.__create_socket(self.game_host, self.game_port)

        self.running = False

        self.games = {}
        self.players = {}
        self.command_queue = queue.Queue()
    
    def __load_config(self):
        pass

    def __load_accounts(self):
        if os.path.isfile(self.accounts_file):
            with open(self.accounts_file, 'r') as f:
                accounts = [set(line.strip().split("\t")) for line in f]
            
            self.accounts = {name: password for (name, password) in accounts }
            return self.accounts
        else:
            return {}
    
    def __save_account(self, username, password):
        hmac = hashlib.pbkdf2_hmac('sha512', password.encode('utf-8'), self.salt.encode('utf-8'), 10000, 64)
        password_hash = binascii.hexlify(hmac).decode('utf-8')
        self.accounts[username] = password_hash

        with open(self.accounts_file, 'a+') as f:
            f.write(username + "\t" + password_hash + "\n")


    def __create_socket(self, host, port):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        sock.bind((host, port))
        sock.listen(5)
        return sock
    
    def __accept_player(self, connection, ip, port):
        player = PlayerClient(connection, ip, port)
        self.players[player.id] = player
        print("Connected with player " + str(ip) + ":" + str(port))
        threading.Thread(target=self.__handle_client, args=(player,)).start()
        

    def __accept_game(self, connection, ip, port):
        game = GameClient(connection, ip, port)
        self.games[game.id] = game
        print("Connected with game instance " + str(ip) + ":" + str(port))
        threading.Thread(target=self.__handle_client, args=(game,)).start()

    def __accept_connection(self):
        readable,_,_ = select.select([self.game_socket, self.player_socket], [], [], 0.001)
        for s in readable:
            connection, (ip, port) = s.accept()
            if s is self.player_socket:
                self.__accept_player(connection, ip, port)
            elif s is self.game_port and ip == self.game_host:
                self.__accept_game(connection, ip, port)
    
    def __handle_client(self, client):
        client.get_console_size()
        while True:
            client.draw_menu()
            command = client.read_command()
            print("COMMAND: " + str(command))
            if command is not None:
                self.command_queue.put((client.type, client.id, command))
            else:
                client.send_message("COMMAND invalid")

    def __process_commands(self):
        while self.command_queue.qsize() > 0:
            (client_type, id, command) = self.command_queue.get_nowait()
            if client_type == "player":
                client = self.players[id]
                self.__execute_player_command(client, command)
            elif client_type == "game":
                game = self.games[id]
                self.__execute_game_command(client, command)

    def __execute_player_command(self, player, command):
        if command.startswith("LOGIN"):
            command = command.split("\t")
            if len(command) == 3:
                command, username, password = command
                hmac = hashlib.pbkdf2_hmac('sha512', password.encode('utf-8'), self.salt.encode('utf-8'), 10000, 64)
                password_hash = binascii.hexlify(hmac).decode('utf-8')
                if self.accounts.get(username) is not None and \
                    self.accounts[username] == password_hash:
                        player.authenticated = True
                        player.send_message("LOGIN successfull")
                else:
                    player.send_message("LOGIN failed")
            else:
                player.send_message("LOGIN failed")
            
        elif command.startswith("REGISTER"):
            command, username, password, *rest = command.split("\t")
            if username in self.accounts.keys():
                player.send_message("REGISTER name_taken")
            else:
                self.__save_account(username, password)
                player.send_message("REGISTER successfull")
        elif command.startswith("LIST"):
            pass
        elif command.startswith("JOIN"):
            game_name, instance_id, *rest = command.split("\t")
            pass
        elif command.startswith("QUIT"):
            player.quit()

    def __execute_game_command(self, game, command):
        if command.startswith("IDENTIFY"):
            game_name, max_nr_players, *rest = command.split("\t")

    def run(self):
        self.running = True
 
        while self.running:
            self.__accept_connection()
            self.__process_commands()

if __name__ == "__main__":
    server = Server()
    server.run()