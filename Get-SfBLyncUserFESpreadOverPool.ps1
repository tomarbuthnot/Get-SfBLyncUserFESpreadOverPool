

# Show how many and what percentage of users in a pool are assigned each FE as their primary server
# This is defined by Lync Server via a hash vaue
# Tom Arbuthnot
# Chris Irons
# Use entirely at your own risk

# Instructions
# Complete PoolName variable, run on a Front End Server
# Will only work for an Enterprise Edition Pool


# User Defined Variables
$Poolname = "MK-SFB-FEPool01.domain.int"




# Script



$FEs = Get-CsPool -Identity $Poolname | Select Computers -ExpandProperty Computers

$OutputCollection=  @()

$Users = Get-CsUser -Filter {RegistrarPool -eq $Poolname} 

$totalUsers = $Users.count

$Users | ForEach-Object {
                            $count = $count + 1
                            
                            $user = $_.SipAddress
                            $FEOrder = $_ | Get-CsUserPoolInfo | Select-Object -ExpandProperty PrimaryPoolMachinesInPreferredOrder


                            $output = New-Object -TypeName PSobject 
                            $output | add-member NoteProperty "SIPAddress" -value $user
                            $output | add-member NoteProperty "FEFirst" -value $FEOrder[0]
                            $output | add-member NoteProperty "FESecond" -value $FEOrder[1]
                            $output | add-member NoteProperty "FEThird" -value $FEOrder[2]
                            
                            $OutputCollection += $output
                            
                            Write-Host "User $count of $totalUsers Complete"
                            }
                
$totalUsers = (Get-CsUser | Where-Object{$_.RegistrarPool -like $Poolname}).count


$OutputCollection2 =  @()

foreach ($FE in $FEs)
{
    
    $totalperFE = ($OutputCollection | Where-Object {$_.FEFirst -eq $FE}).count
    $FEPercentage = ($totalperFE/$totalUsers * 100)

                            
                            $output = New-Object -TypeName PSobject 
                            $output | add-member NoteProperty "Pool" -value $Poolname
                            $output | add-member NoteProperty "FE" -value $fe
                            $output | add-member NoteProperty "Users" -value $totalperFE
                            $output | add-member NoteProperty "Percentage" -value $FEPercentage
                            $OutputCollection2 += $output

}
$OutputCollection2