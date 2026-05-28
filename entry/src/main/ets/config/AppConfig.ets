export class AppConfig{
  static simulationMode:boolean=false //true为模拟，false为真实
}

export function isSimulationMode():boolean{
  return AppConfig.simulationMode
}