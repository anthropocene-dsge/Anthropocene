import React, { useState, useEffect } from 'react';
import { LoginScreen } from './screens/LoginScreen';
import { LoadingScreen } from './screens/LoadingScreen';
import { MenuProgreso } from './screens/MenuProgreso'; 
import type { SaveDataProps } from './screens/MenuProgreso';
import { godotBridge } from './services/godotBridge';
import './index.css';

export default function App() {
  const [screen, setScreen] = useState<'login' | 'loading' | 'menu'>('login');
  const [saveData, setSaveData] = useState<SaveDataProps | null>(null);

  useEffect(() => {
    const unsubscribe = godotBridge.subscribe('SAVE_DATA_RESPONSE', (payload: SaveDataProps | null) => {
      setSaveData(payload);
      
      //  Retraso de 4 segundos para que el usuario aprecie 
      setTimeout(() => {
        setScreen('menu');
      }, 3500);
    });
    
    return unsubscribe;
  }, []);

  const handleLoginSuccess = () => {
    setScreen('loading'); 
    // Le pedimos formalmente a Godot que lea su archivo local en disco
    godotBridge.send('GET_SAVE_DATA');
  };

  return (
    <>
      {screen === 'login' && <LoginScreen onAccessGranted={handleLoginSuccess} />}
      {screen === 'loading' && <LoadingScreen />}
      {screen === 'menu' && <MenuProgreso saveData={saveData} />}
    </>
  );
}