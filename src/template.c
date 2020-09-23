#include <avr/io.h>
#include <util/delay.h>
#include <avr/pgmspace.h>

#define F_CPU  16000000L
#define toggle_delay_ms 1

void init();
void button();
void run();
void end();


int main()
{
  init();
  button();
  run();
  end();
  return 0;
}

void init()
{
  DDRD = 0xff;          // Set Address/Data bus to output
  DDRB |= 0x0f;         // Set control lines to output
  PORTB |= 0x8;         // Set write line high
  DDRC = (1 << 5);      
  PORTC = (1 << 3);     

  PORTC ^= (1 << 5);        
  _delay_ms(200);
  PORTC ^= (1 << 5);
  return;
}

void button()
{
  bool pushed = 0;
  while(!(pushed))
  {
    if(!(PINC & 0x8))     
    {
      _delay_ms(5);
      if(!(PINC & 0x8))   
      {
        PORTC |= (1 << 5);
        pushed = 1;
      }
    }
  }
  return;
}

void run()
{
  uint16_t addr;
  uint16_t x;
  for(x = 0; x < a_length * 2; x+= 2)
  {
    addr = pgm_read_word(&(a_data[x]));      // Put the address on the bus
    PORTD = addr;
    if(addr > 0xff)
    {
      PORTB |= (1 << 0);
    }
    _delay_ms(toggle_delay_ms);

    PORTB ^= (1 << 2);    // Toggle ALE
    _delay_ms(toggle_delay_ms);
    PORTB ^= (1 << 2);
    _delay_ms(toggle_delay_ms);

    PORTD = pgm_read_word(&(a_data[x+1]));  // Put the data on the bus
    _delay_ms(toggle_delay_ms);

    PORTB ^= (1 << 3);    // Toggle !WR
    _delay_ms(toggle_delay_ms);
    PORTB ^= (1 << 3);
    _delay_ms(toggle_delay_ms);

  }
  return;
}

void end()
{
  while(1)
  {
    PORTC ^= (1 << 5);
    _delay_ms(1000);
    PORTC ^= (1 << 5);
    _delay_ms(1000);
  }
  return;
}