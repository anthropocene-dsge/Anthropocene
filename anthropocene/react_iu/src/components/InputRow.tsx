import React, { useState } from 'react';

interface InputRowProps {
  id: string;
  label: string;
  type: string;
  value: string;
  onChange: (val: string) => void;
  placeholder?: string;
  icon: React.ReactNode;
  suffix?: React.ReactNode;
  disabled?: boolean;
}

export function InputRow({ id, label, type, value, onChange, placeholder, icon, suffix, disabled }: InputRowProps) {
  const [focused, setFocused] = useState(false);
  
  return (
    <div style={{ marginBottom: '22px' }}>
      <label htmlFor={id} style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '11px', fontFamily: "'Orbitron', monospace", letterSpacing: '2px', textTransform: 'uppercase', color: focused ? '#F49162' : '#B2A99C', marginBottom: '8px', transition: 'color 0.2s' }}>
        <span style={{ color: focused ? '#F49162' : '#706533', transition: 'color 0.2s' }}>{icon}</span>
        {label}
      </label>
      <div style={{ position: 'relative' }}>
        <input
          id={id}
          type={type}
          value={value}
          placeholder={placeholder}
          disabled={disabled}
          onChange={(e) => onChange(e.target.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
          style={{ width: '100%', background: focused ? 'rgba(112, 101, 51, 0.25)' : 'rgba(112, 101, 51, 0.12)', border: `2px solid ${focused ? '#F49162' : '#706533'}`, borderRadius: '0px', color: '#ffffff', fontFamily: "'Share Tech Mono', monospace", fontSize: '15px', padding: suffix ? '12px 44px 12px 14px' : '12px 14px', boxSizing: 'border-box', transition: 'all 0.2s ease', boxShadow: focused ? '0 0 12px rgba(244,145,98,0.25)' : 'none' }}
        />
        {suffix && <span style={{ position: 'absolute', right: '14px', top: '50%', transform: 'translateY(-50%)' }}>{suffix}</span>}
      </div>
    </div>
  );
}