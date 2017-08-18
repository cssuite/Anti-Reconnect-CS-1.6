#include <amxmodx>

#define CHAT_MSG

#if defined CHAT_MSG
	#include <ColorChat>
#endif

static const PLUGIN[] = "Anti Recconect"
static const VERSION[] = "1.2"
static const AUTHOR[] = "RevCrew"

#define ADMIN read_flags("s")
#define TIME  15

enum 
{
	DETECT_TYPE_ID = 0,
	DETECT_TYPE_IP
}

// Detect Type
new const DETECT_TYPE = DETECT_TYPE_IP

new Trie: g_trie;
new bool:g_need[33]

public plugin_init()
{
	register_plugin(PLUGIN,VERSION,AUTHOR);
	g_trie = TrieCreate();
}
public plugin_end()
{
	TrieDestroy(g_trie)
}
	
public client_connect(id)
{
	new Uid[26], time = 0;
	if(DETECT_TYPE == DETECT_TYPE_IP)
		get_user_ip(id, Uid, charsmax(Uid), 1);
	else
		get_user_authid(id, Uid, charsmax(Uid));

	g_need[id] = false;
	new name[32];
	get_user_name(id, name, charsmax(name))
	
	if( TrieGetCell(g_trie, Uid, time))
	{
		if(time - get_systime(0) > 0)
		{
			g_need[id] = true;
			server_cmd("kick #%d ^" Anti Recconect (%d seconds left) ^"", get_user_userid(id),time - get_systime(0));
			#if defined CHAT_MSG
				client_print_color(0, RED, "^1[^3BlockRec^1] Player ^4%s^1 (^3%s^1) kicked. Reason: ^3Anti Reconnect", name, Uid);
				client_cmd(id,"spk buttons/blip1.wav")
			#endif
			return;
		}
		
		TrieDeleteKey(g_trie, Uid);
	}
				
}

public client_disconnect(id)
{
	if(get_user_flags(id) & ADMIN || g_need[id])
	return;

	new Uid[26];
	if(DETECT_TYPE == DETECT_TYPE_IP)
		get_user_ip(id, Uid, charsmax(Uid), 1);
	else
		get_user_authid(id, Uid, charsmax(Uid));
	
	TrieSetCell(g_trie, Uid, get_systime(0) + TIME);
}
