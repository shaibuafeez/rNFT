import React, { useState } from 'react';
import { Logo } from '../assets/icons';
import Inputfield from '../components/Inputfield';
import Switch from '../components/Switch';
import "../App.css";

function Chat() {
  const [isOn, setIsOn] = useState(false);

  return (
    <div className={`${isOn ? 'bg-backgroundColor' : 'bg-white'} h-full p-5 flex flex-col justify-between relative transition-all`}>
      <div className="flex justify-between items-center">
        <div className="flex items-center gap-2">
          <Logo />
          <p className={`md:block hidden font-bold font-verdana ${isOn ? 'text-white' : 'text-black'} font-size transition-all`}>Sidekick</p>
        </div>
        <div className="bg-widgetBackgroundColor rounded-[10px] shadow p-[10px]  md:w-[309px] w-[293px]">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-[10px]">
              <svg xmlns="http://www.w3.org/2000/svg" width="19" height="25" viewBox="0 0 19 25" fill="none">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M15.2063 10.4218C16.1943 11.6997 16.7897 13.3231 16.7897 15.0835C16.7897 16.8438 16.1817 18.5128 15.162 19.8038L15.0733 19.9146L15.048 19.7712C15.029 19.6538 15.0037 19.5299 14.9783 19.406C14.4717 17.1046 12.8123 15.1291 10.0763 13.5252C8.23333 12.4495 7.17567 11.152 6.897 9.67858C6.71967 8.72669 6.85267 7.76829 7.106 6.9468C7.36567 6.12531 7.74567 5.44074 8.06867 5.02999L9.13267 3.69344C9.31633 3.45873 9.671 3.45873 9.85467 3.69344L15.2063 10.4218ZM16.8847 9.08528L9.766 0.127135C9.633 -0.0423784 9.37333 -0.0423784 9.24033 0.127135L2.11533 9.08528L2.09 9.11788C0.785333 10.7935 0 12.9189 0 15.2334C0 20.6252 4.256 25 9.5 25C14.744 25 19 20.6252 19 15.2334C19 12.9189 18.2147 10.7935 16.9037 9.11788L16.8847 9.08528ZM3.819 10.3957L4.45233 9.59382L4.47133 9.74377C4.484 9.86113 4.503 9.97849 4.52833 10.0958C4.94 12.3191 6.41567 14.1772 8.873 15.6116C11.0137 16.8633 12.255 18.3042 12.616 19.8885C12.768 20.547 12.7933 21.199 12.73 21.7662L12.7237 21.7988L12.692 21.8118C11.7293 22.2943 10.64 22.5681 9.49367 22.5681C5.472 22.5681 2.21033 19.217 2.21033 15.0835C2.21033 13.3101 2.812 11.6736 3.819 10.3957Z" fill="#4DA2FF" />
              </svg>
              <p className="font-verdana text-white">sidekick.sui</p>
            </div>
            <div className="rounded-[5px] p-2 bg-widgetWalletBackgroundColor">
              <p className="font-verdana text-white">420 Sui</p>
            </div>
          </div>
        </div>
      </div>
      <div className="flex justify-center">
        <Inputfield />
      </div>
      <div className="absolute bottom-6 right-4">
        <Switch isOn={isOn} setIsOn={setIsOn} />
      </div>
    </div>
  )
}

export default Chat
