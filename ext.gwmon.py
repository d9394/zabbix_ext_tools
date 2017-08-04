#! /usr/bin/python
# -*- coding: utf-8 -*-
 
import socket
import sys
import hashlib

def create_socket(ip, port):
	global s
	s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	server_address = (ip, int(port))
#	print 'Connecting to %s:%s.' % server_address
	try :
		s.settimeout(1)
		s.connect(server_address)
		s.settimeout(None)
		return "Connect Succeed"
	except:
#		(ErrorType, ErrorValue, ErrorTB) = sys.exc_info()
#		(errno, err_msg) = ErrorValue
#		return "Connect %s:%s failed: %s, errno=%d" % (ip, port, err_msg, errno)
		return "Connect %s:%s failed." % ( ip, port )

def check_login(pwd):
	global s
	data = check_query("SetVersionn","version=2.00")
	data = check_query("QuerySalt","")
	p1 = data[data.find('salt=')+5:].replace("\r\n", "")
	p2 = hashlib.sha256( p1 + hashlib.sha256(pwd).hexdigest()).hexdigest()
	message = "password=%s" % p2
	return check_query("Login",message)

def close_socket():
	global s
#	print 'Closing socket.'
	s.close()

def check_query(qfunction,parameter):
	global s, DEBUG
	message = "type=" + qfunction + "\r\n"
	if parameter<>"" :
		message += parameter + "\r\n"
	message += "\r\n"
	if DEBUG :
		print "Send :%s" % message
	s.sendall(message)
	received = s.recv(16384)
	if DEBUG :
		print "Received :%s" % received
	return received

def count_msg(source,target):
	data = source
	targetlen=len(target)
	pos = 0
	count = 0
	while True:
		pos = data.find(target,pos+targetlen)
		if pos<0 :
			break
		count += int(data[pos+targetlen+1:data.find("\r\n",pos)])
	return count

if __name__ == "__main__":
	global s, DEBUG
#	print len(sys.argv)
#	print sys.argv[1]
	DEBUG = 0
	COMMAND = {}
	if len(sys.argv)<2 :
		print "Command: ext.gwmon.gy HOST,PORT,PASSWORD,COMMNAD,[DEBUG(0|1)]"
		sys.exit(0)
	if len(sys.argv)>3 :
		COMMAND[0]=sys.argv[1]
		COMMAND[1]=sys.argv[2]
		COMMAND[2]=sys.argv[3]
		COMMAND[3]=sys.argv[4]
		if len(sys.argv)>5 :
			COMMAND[4]=sys.argv[5]
	else :
		COMMAND = sys.argv[1].split(",")
	if len(COMMAND)>4 :
		DEBUG = 1
#	print "argv %s " % COMMAND
#	print COMMAND[0]+"&"+COMMAND[1]
	connected = create_socket(COMMAND[0], COMMAND[1])
	if connected.find("Succeed")<0 :
		sys.exit(connected)
	data = check_login(COMMAND[2])
	msg = ""
	if data.find("loginStatus=1")>0 :
		if len(COMMAND[3]) > 5 :
			msg = check_query(COMMAND[3],"")
		else :
			if COMMAND[3] == "01" :
				#检查行情网关柜台连接状态
				data = check_query("QuerySessionStatus","")
				pos = data.find("session.realtime_8016.status")
				if data[pos+29:pos+30]=="1" :
					pos1 = data.find("session.realtime_8016.peerAddress")
					msg = COMMAND[0] + " 柜台行情已连接：" + data[ pos1+34:data.find("\r\n",pos1)]
				else :
				    msg = COMMAND[0] + " 柜台行情未连接！"
			if COMMAND[3] == "02" :
				#检查行情网关与交易所连接状态
				data = check_query("QueryRunStatus","")
				pos = data.find("startState")
				if data[pos+11:pos+12]=="1" :
					pos1 = data.find("serverAddress")
					msg = COMMAND[0] + " 交易所行情已连接：" + data[pos1+14:data.find("\r\n",pos1)]
				else :
				    msg = COMMAND[0] + " 交易所行情未连接！"
			if COMMAND[3] == "03" :
				#统计行情网关的接收包数
				data = check_query("QueryRunStatus","")
				#msg = COMMAND[0] + " : "
				#msg += "接收包数 : " + str(count_msg(data,"pktCount"))
				#msg += ",丢包数 : " + str(count_msg(data,"lostPktCount"))
				#msg += ",错包数 : " + str(count_msg(data,"errorPktCount"))
				msg = str(count_msg(data,"pktCount"))
			if COMMAND[3] == "04" :
				#统计行情网关的失败包数
				data = check_query("QueryRunStatus","")
				msg = COMMAND[0] + " : "
				msg += "丢包数 : " + str(count_msg(data,"lostPktCount"))
				msg += ",错包数 : " + str(count_msg(data,"errorPktCount"))

			if COMMAND[3] == "11" :
				#检查交易网关柜台连接状态
				data = check_query("QuerySessionStatus","")
				pos = data.find("sessionStatus")
				if data[pos+14:pos+15]=="1" :
					pos1 = data.find("compId")
					msg = COMMAND[0] + " 柜台交易已连接：" + data[ pos1+7:data.find("\r\n",pos1)]
				else :
				    msg = COMMAND[0] + " 柜台交易未连接！"
			if COMMAND[3] == "12" :
				#检查交易网关与交易所连接状态
				data = check_query("QueryRunStatus","")
				pos = data.find("commStatus")
				if data[pos+11:pos+12]=="1" :
					pos1 = data.find("serverAddress")
					msg = COMMAND[0] + " 交易所交易已连接：" + data[pos1+14:data.find("\r\n",pos1)]
				else :
				    msg = COMMAND[0] + " 交易所交易未连接！"
			if COMMAND[3] == "13" :
				#检查交易网关与交易所报单状态
				data = check_query("QueryRunStatus","")
				msg = COMMAND[0] + " : "
				pos = data.find("orderCount")
				msg += "委托数 : " + data[pos+11:data.find("\r\n",pos)]
				pos = data.find("orderConfirmCount")
				msg += "，确认数 : " + data[pos+18:data.find("\r\n",pos)]
				pos = data.find("reportCount")
				msg += "，回报数 : " + data[pos+12:data.find("\r\n",pos)]
				pos = data.find("invalidOrderCount")
				msg += "，错单数 : " + data[pos+18:data.find("\r\n",pos)]
				pos = data.find("businessRejectCount")
				msg += "，业务拒绝数 : " + data[pos+20:data.find("\r\n",pos)]
			if COMMAND[3] == "14" :
				#检查交易网关与交易所报单失败
				data = check_query("QueryRunStatus","")
				msg = COMMAND[0] + " : "
				pos = data.find("invalidOrderCount")
				msg += "错单数 : " + data[pos+18:data.find("\r\n",pos)]
				pos = data.find("businessRejectCount")
				msg += "，业务拒绝数 : " + data[pos+20:data.find("\r\n",pos)]

	else :
		msg = "登陆失败"
	print msg
	close_socket()
