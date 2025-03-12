import SuiIcon from "./image 1.png";

export const Logo = () => {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="36" viewBox="0 0 32 36" fill="none">
      <path fill-rule="evenodd" clip-rule="evenodd" d="M15.8794 0L32 9.25478V14.6753L15.8794 5.14408L4.71314 11.8156V13.9639L20.6083 23.4189L16 26L0 16.9003V8.83179L15.8794 0Z" fill="#57FFE1" />
      <path fill-rule="evenodd" clip-rule="evenodd" d="M16.1206 36L0 26.7452V21.3247L16.1206 30.8559L27.2869 24.1844V22.0361L11.3917 12.5811L16 10L32 19.0997V27.1682L16.1206 36Z" fill="#57FFE1" />
    </svg>
  );
};

export const SuiLogo = ({ width, height }) => {
  return (
    <img src={SuiIcon} width={width || "31"} height={height || "31"} alt="Sui Logo" />
  );
};