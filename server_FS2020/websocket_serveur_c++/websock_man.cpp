#define ASIO_STANDALONE
#define _WEBSOCKETPP_CPP11_THREAD_

#include <websocketpp/config/asio_no_tls.hpp>

#include <websocketpp/server.hpp>

#include <iostream>
#include <set>

#include "sim_server.h"
#include <websocketpp/common/thread.hpp>

typedef websocketpp::server<websocketpp::config::asio> server;

using websocketpp::connection_hdl;
using websocketpp::lib::placeholders::_1;
using websocketpp::lib::placeholders::_2;
using websocketpp::lib::bind;

using websocketpp::lib::thread;
using websocketpp::lib::mutex;
using websocketpp::lib::lock_guard;
using websocketpp::lib::unique_lock;
using websocketpp::lib::condition_variable;

/* on_open insert connection_hdl into channel
 * on_close remove connection_hdl from channel
 * on_message queue send to all channels
 */

websocketpp::frame::opcode::value opcode_client = websocketpp::frame::opcode::value::TEXT;
bool check_co = false;
bool cond_sortie =false;

float ktsvals[] = {0.0,0.1,-0.2,0.4,-0.1,0.0,-0.3,0.3};
int compt;

enum action_type {
    SUBSCRIBE,
    UNSUBSCRIBE,
    MESSAGE
};

struct action {
    action(action_type t, connection_hdl h) : type(t), hdl(h) {}
    action(action_type t, connection_hdl h, server::message_ptr m)
      : type(t), hdl(h), msg(m) {}

    action_type type;
    websocketpp::connection_hdl hdl;
    server::message_ptr msg;
};

void send_a_message(server* s, websocketpp::connection_hdl hdl, std::string payload);

class broadcast_server {
public:
    broadcast_server() {
        // Initialize Asio Transport
        m_server.init_asio();

        m_server.set_access_channels(websocketpp::log::alevel::none);
        m_server.clear_access_channels(websocketpp::log::alevel::frame_payload);
        // Register handler callbacks
        m_server.set_open_handler(bind(&broadcast_server::on_open,this,::_1));
        m_server.set_close_handler(bind(&broadcast_server::on_close,this,::_1));
        m_server.set_message_handler(bind(&broadcast_server::on_message,this,::_1,::_2));
    }

    void run(uint16_t port) {
        // listen on specified port
        m_server.listen(port);

        // Start the server accept loop
        m_server.start_accept();

        // Start the ASIO io_service run loop
        try {
            m_server.run();
        } catch (const std::exception & e) {
            std::cout << e.what() << std::endl;
        }
    }

    void on_open(connection_hdl hdl) {
        {
            check_co = true;
            lock_guard<mutex> guard(m_action_lock);
           // std::cout << "on_open" << std::endl;
            m_actions.push(action(SUBSCRIBE,hdl));
        }
        m_action_cond.notify_one();
    }

    void on_close(connection_hdl hdl) {
        {
            lock_guard<mutex> guard(m_action_lock);
            //std::cout << "on_close" << std::endl;
            m_actions.push(action(UNSUBSCRIBE,hdl));
        }
        m_action_cond.notify_one();
    }

    void on_message(connection_hdl hdl, server::message_ptr msg) {
        // queue message up for sending by processing thread
        {
            lock_guard<mutex> guard(m_action_lock);
            //std::cout << "on_message" << std::endl;
            m_actions.push(action(MESSAGE,hdl,msg));
        }
        m_action_cond.notify_one();
    }

    void process_messages() {
        while(!cond_sortie) {
            unique_lock<mutex> lock(m_action_lock);

            while(m_actions.empty()) {
                m_action_cond.wait(lock);
            }

            action a = m_actions.front();
            m_actions.pop();

            lock.unlock();

            if (a.type == SUBSCRIBE) {
                lock_guard<mutex> guard(m_connection_lock);
                m_connections.insert(a.hdl);
            } else if (a.type == UNSUBSCRIBE) {
                lock_guard<mutex> guard(m_connection_lock);
                m_connections.erase(a.hdl);
                cond_sortie = true;
                std::cout << "sortie du process_messages\n";
                return;
            } else if (a.type == MESSAGE) {
                lock_guard<mutex> guard(m_connection_lock);

                con_list::iterator it;
                for (it = m_connections.begin(); it != m_connections.end(); ++it) {
                    m_server.send(*it,a.msg);
                }
            } else {
                // undefined.
            }
        }
        return;
    }

    void send_messages() {
        while(!check_co) {
            Sleep(100);
        }
        //std::cout << "check_co passé" << std::endl;
        while (!cond_sortie) {
            handleDispatch();
            lock_guard<mutex> guard(m_connection_lock);

            con_list::iterator it;
            for (it = m_connections.begin(); it != m_connections.end(); ++it) {
                send_a_message(&m_server,*it,"50");
            }           
            Sleep(500);
        }
        std::cout << "Sortie de send_messages\n";
        return;
    }

private:
    typedef std::set<connection_hdl,std::owner_less<connection_hdl> > con_list;

    server m_server;
    con_list m_connections;
    std::queue<action> m_actions;

    mutex m_action_lock;
    mutex m_connection_lock;
    condition_variable m_action_cond;
};

void send_a_message(server* s, websocketpp::connection_hdl hdl, std::string payload) {
    try {
        compt = (compt+1)%8;
        string tostring = to_string(KtsVal +ktsvals[compt]);
        s->send(hdl, tostring, opcode_client);
        std::cout << "value envoyee : " << tostring << std::endl;
    } catch (websocketpp::exception const & e) {
        cond_sortie = true;
        std::cout << "Echo failed because: "
                  << "(" << e.what() << ")" << std::endl;
    }
}

int main(int argc, char *argv[]) {
    int nport;
    if (argc > 1) {
        nport=stoi(argv[1]);
    }
    else {
        nport=9002;
    }

    initSimEvents();
    try {
    broadcast_server server_instance;

    // Start a thread to run the processing loop
    
    
    thread t(bind(&broadcast_server::process_messages,&server_instance));
    thread t2(bind(&broadcast_server::send_messages,&server_instance));

    // Run the asio loop with the main thread
    server_instance.run(nport);

    t.join();
    t2.join();
    closeDispatch();


    } catch (websocketpp::exception const & e) {
        std::cout << e.what() << std::endl;
    }
    return 0;
}
