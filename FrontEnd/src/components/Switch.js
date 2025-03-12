function Switch({ isOn, setIsOn }) {
  return (
    <div
      className={`w-16 h-8 md:flex hidden items-center rounded-full p-1 cursor-pointer bg-black`}
      onClick={() => setIsOn(!isOn)}
    >
      <div
        className={`bg-switchThumbBackgroundColor w-6 h-6 rounded-full shadow-md transform duration-300 ease-in-out ${isOn ? 'translate-x-8' : ''}`}
      >
        {isOn ? (
          <i className={`fas fa-moon text-white text-xs flex items-center justify-center h-full`}></i>
        ) : (
          <i className="fas fa-sun text-white text-xs flex items-center justify-center h-full"></i>
        )
        }
      </div>
    </div>
  );
};

export default Switch;