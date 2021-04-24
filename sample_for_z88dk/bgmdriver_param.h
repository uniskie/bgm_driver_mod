static const char *p_start_address				= 0x0a000;
static const int driver_size					= 0x06f8;
void (* bgmdrv_setup_htimi)( void )				= 0x0a693;
void (* bgmdrv_restore_htimi)( void )			= 0x0a6b9;
void (* bgmdrv_play)( void *p_data )			= 0x0a6c7;
void (* bgmdrv_stop)( void )					= 0x0a04b;
int  (* bgmdrv_check_play)( void )				= 0x0a6e5;
void (* bgmdrv_play_se)( void *p_data )			= 0x0a6cf;
void (* bgmdrv_fade_out)( unsigned int speed )	= 0x0a6d7;