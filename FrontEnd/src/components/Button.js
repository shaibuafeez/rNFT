import React from 'react';
import "@fontsource/inter"

function Button({ title }) {
  return (
    <button className="py-[12px] px-[45.5px] border-none rounded-[5px] outline-none bg-black">
      <p className="font-inter font-medium text-white">{title}</p>
    </button>
  )
}

export default Button;
