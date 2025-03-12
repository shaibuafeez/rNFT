function Inputfield() {
  return (
    <div className="relative md:w-auto w-full">
      <input
        type="text"
        className="bg-textFieldBackgroundColor text-white rounded-[10px] md:w-[767px] w-full h-[52px] pl-4 pr-16 focus:outline-none"
      />
      <button className="absolute right-[6px] top-[6px] bg-buttonBackgroundColor h-10 w-10 rounded-[6px]"></button>
    </div>
  )
};

export default Inputfield;